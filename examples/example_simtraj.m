%% get access to the directories containing the code

% directory containing networktools code
addpath('../networktools')
addpath('../code')

%% load in an original ER image
% and an image that has been masked using Ilastik
dirname = './';
fname = 'example_ER_network_1Hz.tif';
bwfname = 'example_ER_network_1Hz_masked.tif';

info = imfinfo([dirname fname]);

% convert pixels to um
pxperum = info(2).XResolution;

img = imread([dirname fname], 2);
bwimg = imread([dirname bwfname],2);

imshowpair(img,bwimg,'montage')

%% Process the masked image to extract network structure
[NT,skelimage,opt] = getNetworkFromBWImage(bwimg);

% plot network overlaid on image
imshow(img,[])
set(gca,'Position',[0,0,1,1])
hold all
plotopt = struct('nodecolor',[1 0 0],'nodesize',20);
plotopt.edgeplotopt = {'LineWidth',1,'Color','g'};
NT.plotNetwork(plotopt)
hold off

%% Run simulations of diffusing particles on the network
dt = 0.0107; % seconds per frame
% each of the network structures is separated by 100 frames (~1 sec)
Dum = 1.5; % diffusivity in um^2/s

% set up simulation options
simopt = struct();
simopt.dt = 0.1; % simulation timestep for the particles (in frames)
nStep=1e4; % total number of steps for each particle
nPart = 100; % number of particles to simulate
simopt.D = Dum*pxperum^2*dt; % diffusivity in px^2/frame
simopt.printEvery = 1000; % how often to print simulation output
simopt.saveEvery = 10; % save only every 10th particle position
% the resulting saved trajectories will have 1 point every frame

% run the simulation
[savePos,saveTimes,opt] = randomWalkNetwork(NT,nPart,nStep,simopt);

% convert simulated trajectories from edges and positions along them
% to trajectories in 2D space
% tracklist is a cell list, where each element is an nPart x 3 array
% columns 1,2 are xy positions; column 3 is corresponding frame
tracklist = savePos2Traj(NT,savePos);

%% plot a few trajectories
NT.plotNetwork()
hold all
for tc = 1:10:nPart
    track = tracklist{tc};
    plot(track(:,1),track(:,2),'.-','MarkerSize',15)
end
hold off

%% break up trajectories whenever they jump to nonconnected edge
% this uses code intended for projecting 2D trajectories onto a network
opt = struct('scl',1,'breakedgejump',true);
[projtracklist,allrawtracks,projedgepos,opt] = trajProjNetwork(NT,tracklist,[1,nStep+1],opt);


%% get raw MSD
% calculate MSD, using nonoverlapping windows
[MSDtot0,cnttot0,sterrtot0] = MSDensemble(projtracklist,'overlap',@(k) k);
% time values for the simulated trajectories (in frames);
tvals = (1:length(MSDtot0))*simopt.dt*simopt.saveEvery;

loglog(tvals,MSDtot0,tvals,2*simopt.D*tvals)

%% Unraveling
% range of D values to try for unraveling (in px^2/frame)
Dvals = logspace(log10(0.2),log10(2),20);
unravelopt = struct('timestep',simopt.dt*simopt.saveEvery,'dodisplay',1,'errfunc','Rsq','mininterp',100,'minct',20);
ntrial = 1; % only do 1 sample during unraveling

[Dopt,allMSDtot,allcnttot,avglogerrvals,stelogerrvals,pfit,Rsqvals,allMSDinterp,tinterp] = estimateDfromTraj_multiNT(ntrial,projedgepos,[NT],ones(length(projedgepos),1),Dvals,unravelopt);


%% plot error function G(D) vs the value of D used for unraveling
figure
plot(Dvals,1-Rsqvals)

%% unravel with optimal D to look at final MSD curve
D = Dopt;
tracklistunravel = {};
for pc = 1:length(tracklist)
    posinfo = projedgepos{pc}';
    for tc = 1:ntrial
        unraveltraj = unravelingInfLine(NT,posinfo,simopt.dt*simopt.saveEvery,D);
        track = [unraveltraj,zeros(size(unraveltraj,1),1)];
        tracklistunravel{end+1} = track;
    end
end

% Plot unraveled MSD
[MSDtot,cnttot,sterrtot] = MSDensemble(tracklistunravel,'overlap',@(k) k);
tvals = (1:length(MSDtot))*simopt.dt*simopt.saveEvery;

loglog(tvals,MSDtot,tvals,2*simopt.D*tvals)

%% FINAL value: estimated D in um per sec (should be very similar to the value of Dum)
Dest = Dopt/dt/pxperum^2
