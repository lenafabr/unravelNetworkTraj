function tracklist = loadCleanTrackList(filename,options) %stepcutoff,mintracklen,region,maxframestep)

% default parameters
% maximum spatial step
opt.stepcutoff = 0.6; 
% minimal length of trajectory to save
opt.mintracklen = 20;
% only keep points within a given region
opt.region= NaN;
% maximum frame separation between consecutive points
opt.dtcutoff = 2;
% supply pre-loaded tracklist
opt.tracklist = {};

if (exist('options','var'))
    opt = copyStruct(options,opt);
end

% load track data from a file
% break up tracks at steps bigger than stepcutoff
% remove all tracks touching edges
% keep only tracks above a minimum length

if (isempty(opt.tracklist))
    tracklist = loadTrackList(filename);
else
    tracklist = opt.tracklist;
end
ntrack = length(tracklist);

% if region is supplied (boundary coordinates), filter only those
% trajectory points within the region
if (~isnan(opt.region))
    for tc = 1:ntrack
        track = tracklist{tc};
        keep = inpolygon(track(:,1),track(:,2),opt.region(:,1),opt.region(:,2));
        tracklist{tc} = track(keep,:);
    end
end

%% break trajectories at particularly large steps

newtracklist = {};
for tc = 1:ntrack
    track = tracklist{tc};
    
    spacesteps = diff(track(:,1:2));
    dsteps = sqrt(sum(spacesteps.^2,2));
    dt = diff(track(:,3));
    
    breakind = find(dsteps>opt.stepcutoff | dt > opt.dtcutoff);
    
    newtracks= breakTrack(track,breakind,opt.mintracklen);
    newtracklist= [newtracklist newtracks];
end

tracklist = newtracklist;
%% remove any trajectories that touch edges

% get max edges of trajectories
hitedge = false*ones(1,length(tracklist));
for xc = 1:2
    minlist = cellfun(@(x) min(x(:,xc)), tracklist);
    maxlist = cellfun(@(x) max(x(:,xc)), tracklist);
    
    minmax(xc,:) = [min(minlist),max(maxlist)];
    
    hitmin = (minlist==minmax(xc,1));
    hitmax = (maxlist==minmax(xc,2));
    
    hitedge = hitedge | (hitmin | hitmax);    
end

tracklist = tracklist(~hitedge);



end