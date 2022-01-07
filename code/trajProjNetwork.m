
function [allprojtrack,allrawtracks,allprojedgepos,opt] = trajProjNetwork(NT,tracklist,framerange,options)

% project trajectories onto network structure
% NT = network structure
% tracklist = list of trajectories
% framerange = start and end frame to consider for this network
% im = optional image for display
% returns cell array with following columns: x_proj, y_proj, frame, edge index,
% fractional length along edge, distance from original to projected point
% usetracklist is the raw trajectories, filtered for appropriate time
% range, before projection
% output: 
% allprojtrack = trajectory list of projected tracks
% usetracklist = original points corresponding to the projected
% trajectories
% allprojedgepos = trajectory list of pairs (edge index, contour length along
% edge) for each projected track


opt = struct();
opt.mintracklen = 10; % minimum track length along network
% maximum distance for edge end point
% to include the edge in the search for projection
opt.maxnodedist = 10;

% max projected distance allowed (in px)
opt.maxprojdist = 1.5;

% scaling from trajectory coords to pixels
opt.scl = 0.16;
opt.shift = [0;0]; % shift of trajectories in pixels

% break up trajectories if projected to non-adjacent edge?
opt.breakedgejump = false;

% if positive value, break trajectories when step size is bigger than this
% in px
opt.breakstepsize = -1; 

opt.im = [];
%%
if (exist('options','var'))
    opt = copyStruct(options,opt);
end
%%

if (isempty(opt.im))
    dodisplay = 0;
else
    dodisplay = 1;
end

startframe = framerange(1);
endframe = framerange(2);

if (dodisplay>0)
    %imshowpair(skelimage,im)
    imshow(opt.im)
    hold all
    plot(NT.nodepos(:,1),NT.nodepos(:,2),'r.','MarkerSize',20)
    
    for ec = 1:length(NT.edgepath)
        edge = NT.edgepath{ec};
        plot(edge(:,1),edge(:,2),'g','LineWidth',2)
    end
    
    cmap = lines(length(tracklist));
end

%%
minframes = cellfun(@(x) min(x(:,3)),tracklist);
maxframes = cellfun(@(x) max(x(:,3)),tracklist);
%% extract the part of each trajectory that covers the right frames
usetracklist = {};
for tc = 1:length(tracklist)
    if (minframes(tc) > endframe | maxframes(tc)<startframe); continue; end
    
    track = tracklist{tc};
    track(:,1) = track(:,1)/opt.scl+opt.shift(1);
    track(:,2) = track(:,2)/opt.scl+opt.shift(2);
    track(:,4) = tc; % note original track ID
    
    breakind = find(track(:,3)<startframe | track(:,3)>endframe);
    
    newtraj = breakTrack(track,breakind,opt.mintracklen);
    usetracklist = [usetracklist newtraj];
end

%% project trajectories onto the network
if (dodisplay>0)
    imshow(opt.im)
    hold all
    plot(NT.nodepos(:,1),NT.nodepos(:,2),'r.','MarkerSize',20)
    
    for ec = 1:length(NT.edgepath)
        edge = NT.edgepath{ec};
        plot(edge(:,1),edge(:,2),'g','LineWidth',2)
    end
    
    cmap = lines(length(tracklist));
end


allprojtrack = {};
allprojedgepos = {};
allrawtracks = {};
for tc = 1:length(usetracklist)
   % [tc, length(usetracklist)]
    %%
    track = usetracklist{tc};
    %track(:,1) = track(:,1)/opt.scl+opt.shift(1);
    %track(:,2) = track(:,2)/opt.scl+opt.shift(2);
    
    if (dodisplay>0)
        plot(track(:,1),track(:,2),'o-','Color',cmap(tc,:))
    end
    
    % get all nodes within a max radius of the track center of mass
    com = mean(track(:,1:2),1);
    % how big is the track?
    trackext = track(:,1:2)-com;
    trackrange = max(trackext) - min(trackext);
    distcutoff = max(trackrange)+opt.maxnodedist;
    
    % check distance to each edge endpoint
    diffs1 = NT.nodepos(NT.edgenodes(:,1),:)-com;
    dists1 = sqrt(sum(diffs1.^2,2));
    diffs2 = NT.nodepos(NT.edgenodes(:,2),:)-com;
    dists2 = sqrt(sum(diffs2.^2,2));
    closeedges = find(dists1<opt.maxnodedist | dists2 < distcutoff);
    
    if (isempty(closeedges))
        continue
    end
        
%     if (dodisplay>0)
%         plot(com(1),com(2),'m*','MarkerSize',20)
%         % plot(NT.nodepos(closenodes,1),NT.nodepos(closenodes,2),'mo','MarkerSize',10)
%     end
    
    %%
    distances = zeros(size(track,1),length(closeedges));
    edgefrac = distances;
    xy = zeros(size(track,1),2,length(closeedges));
    for cc = 1:length(closeedges)
        %%
        ec = closeedges(cc);
        edge = NT.edgepath{ec};
        % go through each edge attached to the close nodes
        if (dodisplay>0)
            plot(edge(:,1),edge(:,2),'m.-','MarkerSize',10)
            %text(edge(2,1),edge(2,2),sprintf('%d',ec))
        end
        % find closest point along this edge
        [xy(:,:,cc),distances(:,cc),edgefrac(:,cc)] = distance2curve(edge,track(:,1:2));
    end
    
    %% map each track point based on min distance
    projtrack = zeros(size(track,1),7);
    projedgepos = zeros(size(track,1),2);
    doesjump = false(size(track,1),1);
    for pc = 1:size(track,1)
        [mindist,cc] = min(distances(pc,:));
        
        % store projected coords, edge index, edge frac
        projtrack(pc,:) = [xy(pc,:,cc) track(pc,3) closeedges(cc) edgefrac(pc,cc) distances(pc,cc) track(pc,4)];
        
        % store projected point in terms of which edge, how far along edge
        ec = closeedges(cc);
        edgedist = edgefrac(pc,cc)*NT.edgelens(ec);
        projedgepos(pc,:) = [ec,edgedist];
        
        if (opt.breakedgejump & pc>1)
            % check if trajectory jumps to a non-adjacent edge
            ecprev = projedgepos(pc-1,1);
            nc1 = NT.edgenodes(ecprev,1); nc2 =NT.edgenodes(ecprev,2);
            % all edges adjacent to previous one (including itself
            edgeedges = [NT.nodeedges(nc1,1:NT.degrees(nc1)) NT.nodeedges(nc2,1:NT.degrees(nc2))];
            doesjump(pc-1) = ~ismember(ec,edgeedges);
            %(ec==ecprev | ismember(ec,NT.edgeedges(ecprev,:)));            
        end
    end            
    %%
    dobreak = projtrack(:,6)>opt.maxprojdist; % break at large spatial jumps
    if (opt.breakedgejump) % break at jump to nonadjacent edge
        dobreak = dobreak | doesjump;
    end
    % break when step sizes are too big
    if (opt.breakstepsize>0)
        diffs = projtrack(2:end,1:2)-projtrack(1:end-1,1:2);
        dists = sqrt(sum(diffs.^2,2));
        dobreak = dobreak(1:end-1) | dists > opt.breakstepsize;
    end    
    breakind = find(dobreak);            
    newprojtracks = breakTrack(projtrack,breakind,opt.mintracklen);
    rawtracks = breakTrack(track,breakind,opt.mintracklen);
        
    allrawtracks = [allrawtracks rawtracks];
    allprojtrack = [allprojtrack newprojtracks];            
    
    
    newprojedgepos = breakTrack(projedgepos,breakind,opt.mintracklen);
    allprojedgepos = [allprojedgepos newprojedgepos]; 
    
    if (dodisplay>0)
        for pc = 1:length(newprojtracks)
            projtrack2 = newprojtracks{pc};
            plot(projtrack2(:,1),projtrack2(:,2),'c.-','MarkerSize',10)
        end
    end
    
end
if (dodisplay>0)
    hold off
end
