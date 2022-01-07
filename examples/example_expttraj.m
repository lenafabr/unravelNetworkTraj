%% load in masked ER images
% these were collected from frames 1, 101, 201, etc. processed via elastic
% also load in raw images for visualization

dirname = './';
% raw images
fname = 'example_ER_network_1Hz.tif';
% masked images
bwfname = 'example_ER_network_1Hz_masked.tif';

info = imfinfo([dirname fname]);
nimg = length(info);

% convert pixels to um
pxperum = info(1).XResolution;

imgs = zeros(info(1).Width,info(1).Width,nimg);
bwimgs = imgs;

for fc = 1:nimg
    imgs(:,:,fc) = imread([dirname fname], fc);
    bwimgs(:,:,fc) = imread([dirname bwfname],fc);    
    networkframes(fc) = 100*(fc-1)+1; % what frame each img corresponds to
end

%% Process each masked image to extract network structure
% this can take a couple of minutes
clear allnetworks
for fc = 1:nimg
    fc
    [NT,skelimage,opt] = getNetworkFromBWImage(bwimgs(:,:,fc));
    allnetworks(fc) = NT;
end

%% Load in particle trajectories (originally extracted with TrackMate)
% 3rd column assumed to contain frame number
% trajectories are in um

dirname = './';
filename = [dirname 'Halo-Sec61-TA-100Hz_003_Tracks.csv'];

% cut off trajectory if taking steps > 0.6, if total length <20 frames, if
% missing for 2 or more frames
trackopt = struct('stepcutoff',0.6,'mintracklen',20,'dtcutoff',2);
tracklist = loadCleanTrackList(filename, trackopt);

% number of tracks and length of each
ntrack = length(tracklist);
tracklens = cellfun(@(x) size(x,1), tracklist);

% first and last frame of each track
minframes = cellfun(@(x) min(x(:,3)),tracklist);
maxframes = cellfun(@(x) max(x(:,3)),tracklist);

%% visualize raw trajectories on top of network (for a particular frame range)

% how much to shift trajectories to align with structure (in px)
shift = [0,1];

% which image to use
fc=10;
framecent = networkframes(fc);
dframe = networkframes(2)-networkframes(1);
% frames within a range of +/- 100 of this image
frames = framecent-dframe:framecent+dframe;

% show the image
im = imgs(:,:,fc);
% normalize image to btwn 0 and 1
im = im/max(im(:));
imshow(im,[0,0.6])
set(gca,'Position',[0.05,0.05,0.9,0.9]);

% plot network over the image
NT = allnetworks(fc);
hold all
plotopt = struct('nodesize',30,'nodecolor',[1 0 0]);
plotopt.edgeplotopt = {'Color','g','LineWidth',2};
NT.plotNetwork(plotopt)
title(filename,'Interpreter','none')

% superimpose the pieces of track within this frame range
hold all
for tc = 1:length(tracklist)
    track = tracklist{tc};
    
    [~,ia,ib] = intersect(track(:,3),frames);
    
    if (~isempty(ia))
        plot(track(ia,1)*pxperum+shift(1),track(ia,2)*pxperum+shift(2),'.-')
    end
end
hold off

%% Project all trajectories onto network
allprojtracklist ={}; % projected trajectories in 2D
allprojedgepos = {}; % projected trajectories in terms of position along edge
allrawtracklist = {}; % raw trajectory chunks (not projected)
whichnetwork = []; % which network projected trajectory belongs to

for nc = 1:length(allnetworks)
    
    % frame corresponding to an image
    framecent = networkframes(nc);
   % network corresponding to this image
    NT = allnetworks(nc);
   
    %% project trajectories onto network structure
    % convert projected trajectories into relative positions along edge
    % NOTE: projected trajectories are in px
    dframe = networkframes(2)-networkframes(1);
    framerange = [framecent-dframe; framecent+dframe];
    options = struct(); % options for projection
    options.shift = shift; % shift to align trajectories with image
    options.maxprojdist = 2; % max projected distance allowed, in px
    options.scl = 1/pxperum;
    options.breakstepsize = 5; % break at large step jumps in px    
    
    % break up trajectories if they jump to a non-adjacent edge
    options.breakedgejump = true;
    
    % these trajectories are now in units of pixels!
    [projtracklist,rawtracklist,projedgepos] = trajProjNetwork(NT,tracklist,framerange,options);
    
    allprojtracklist = [allprojtracklist projtracklist];
    allrawtracklist = [allrawtracklist rawtracklist];
    allprojedgepos = [allprojedgepos projedgepos];    
    
    whichnetwork = [whichnetwork, nc*ones(1,length(projedgepos))];
    
    
    [nc length(allprojedgepos)]
end
projoptions = options;

%% get raw MSD for projected trajectories
% calculate MSD, using nonoverlapping windows
[MSDtot0,cnttot0,sterrtot0] = MSDensemble(projtracklist,'overlap',@(k) k);
% time values for the simulated trajectories (in frames);
tvals = (1:length(MSDtot0))*simopt.dt*simopt.saveEvery;

loglog(tvals,MSDtot0,tvals,2*simopt.D*tvals)

%% Unraveling
% range of D values to try for unraveling (in px^2/frame)
Dvals = logspace(log10(0.2),log10(2),20);
unravelopt = struct('dodisplay',1,'errfunc','Rsq','mininterp',100,'minct',20);
ntrial = 1; % only do 1 sample during unraveling

[Dopt,allMSDtot,allcnttot,avglogerrvals,stelogerrvals,pfit,Rsqvals,allMSDinterp,tinterp] = estimateDfromTraj_multiNT(ntrial,allprojedgepos,allnetworks,whichnetwork,Dvals,unravelopt);


%% plot error function G(D) vs the value of D used for unraveling
figure
plot(Dvals,1-Rsqvals)

%% unravel with optimal D to look at final MSD curve
D = Dopt;
tracklistunravel = {};
for pc = 1:length(allprojedgepos)
    posinfo = allprojedgepos{pc}';
    for tc = 1:ntrial
        unraveltraj = unravelingInfLine(allnetworks(whichnetwork(pc)),posinfo,1,D);
        track = [unraveltraj,zeros(size(unraveltraj,1),1)];
        tracklistunravel{end+1} = track;
    end
end

% Plot unraveled MSD
[MSDtot,cnttot,sterrtot] = MSDensemble(tracklistunravel,'overlap',@(k) k);
tvals = (1:length(MSDtot));

loglog(tvals,MSDtot,tvals,2*Dopt*tvals)

%% FINAL value: estimated D in um per sec 
Dest = Dopt/dt/pxperum^2

