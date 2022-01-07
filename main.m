% this script demonstrates how to run simulations and perform unraveling on
% the simulated trajectories.
%% Loading in example network object
% load in the network object
% use the following code to rescale the network if needed
% NT.nodepos = NT.nodepos*scl;
% for ec = 1:NT.nedge
%     NT.edgepath{ec} = NT.edgepath{ec}*scl;
% end
% only keep the largest connected component of the graph
NT.keepLargestConnComp();
% set up the cumulative edge length arrays
NT.setCumEdgeLen();

%% simulating Brownian dynamics on the network
% set the optional parameters for simulation
opt = struct();
% save the positions every five steps
opt.saveEvery = 5;
% set the time step
opt.dt = 0.005;
% set the diffusivity to 1
opt.D = 1;
% simulate the process with 100 particles
nPart = 100;
% run the simulation with 10000 steps
nStep=10000;
% print results in console every 1000 steps
opt.printEvery = 1000;
% running the simulation
% savePos is a 3d matrix that stores the
savePos = randomWalkNetwork(NT, nPart, nStep, opt);
% convert the positions to network coordinates
tracklist = SavePos2Traj(NT, savePos);

%% plotting the trajectories (optional)
% plot the network
NT.plotNetwork()
hold all
% plot the tracks
for tc = 1:length(tracklist)
    track = tracklist{tc};
    plot(track(:,1),track(:,2),'.-')
end
hold off

%% get raw MSD (optional)
% get the raw MSD of the tracks
MSDtot0 = MSDensemble(projtracklist, 'overlap', @(k) k);
% get the time values points
tvals = (1 : length(MSDtot0)) * opt.dt * opt.saveEvery;
% plotting the raw MSD on a loglog plot
loglog(tvals, MSDtot0, tvals, 2 * opt.D * tvals)

%% Unraveling
% generate the possible diffusivity values on a log space
Dvals = logspace(log10(0.2),log10(2),20);
% perform unraveling with 10 trials
ntrial = 10;

% set up unrevaling parameters
unravelopt = struct('timestep', opt.dt * opt.saveEvery, ...
    'dodisplay', 1, 'errfunc', 'Rsq', 'mininterp', 100, 'minct', 20);

% get the diffusivity "Dopt" with the least residual
Dopt = estimateDfromTraj_multiNT(ntrial, tracklist,[NT], ... 
    ones(length(tracklist),1), Dvals, unravelopt);

%% unravel with optimal D
tracklistunravel = cell(length(tracklist), 1);
for pc = 1 : length(tracklist)
    posinfo = tracklist{pc}';
    unraveltraj = ...
        unravelingInfLine(NT, posinfo, opt.dt * opt.saveEvery, Dopt);
    track = [unraveltraj, zeros(size(unraveltraj, 1), 1)];
    tracklistunravel{pc} = track;
end

%% Plot unraveled MSD (optional)
MSDtot = MSDensemble(tracklistunravel, 'overlap', @(k) k);
loglog(tvals, MSDtot, tvals, 2 * opt.D * tvals);
