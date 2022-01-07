function [Dopt,allMSDtot,allcnttot,avglogerrvals,stelogerrvals,pfit,Rsqvals,allMSDinterp,tinterp,bootsam] = estimateDfromTraj_multiNT(ntrial,savePos,NTs,whichnetwork,Dvals,options)
% input:
% ntrial = number of unravelling trials
% nPart = number of particles
% savePos = edge index and position along edge, from simulations
% alternately can provide a cell array of trajectories
% NTs = list of network
% whichnetwork = index of which network to use for each particle
% Dvals = guesses for diffusivity
% options = optional other parameters

% default options
opt = struct();
opt.timestep = 1;

% bootstrap trajectories for each trial
opt.dobootstrap = false;

% display plots
opt.dodisplay = 0;
opt.mininterp = 0;
opt.minct = 20;
opt.errfunc = 'avglog';

% when calculating Rsq, only keep MSDs below a certain cutoff
opt.RsqMSDmax = inf;

% use a polynomial to interpolate the error fucntion so that gives a
% smooth minimal for D, insert a value so that we can finer the grid by
% interpolation eg: opt.mininterp = 20 means that it will increase the
% spacing for Dvals 20 times.
% copy passed options
opt.power = 0;
%power function approximation
if (exist('options','var'))
    opt = copyStruct(options,opt);
end

%% Bootstrpping sample (take different colllection)
if (opt.dobootstrap)
    nparticle = length(savePos);
    [bootstat,bootsam] = bootstrp(ntrial,@mean,1:nparticle);
else
    bootsam = 1:length(savePos);
end

%% Try calculating separate MSD for each unravelling run.
% average the error functions?
clear allMSDtot allcnttot
cmat = jet(length(Dvals));
for dc = 1:length(Dvals)
    D = Dvals(dc);
    
    for tc = 1:ntrial
        if (opt.dobootstrap)
            trackind = bootsam(:,tc);
        else
            if (iscell(savePos))
                nparticle = length(savePos);
            else
                nparticle = size(savePos,1);
            end
            trackind = 1:nparticle;
        end
        for pcc = 1:length(trackind);
            pc = trackind(pcc);
            
            if (iscell(savePos)) % edge position provided as a cell list
                posinfo = savePos{pc}';
            else
                posinfo = squeeze(savePos(pc,:,:)); % edge position provided as an array
            end
            unraveltraj = unravelingInfLine(NTs(whichnetwork(pc)),posinfo,opt.timestep,D);
            track = [unraveltraj,zeros(size(unraveltraj,1),1)];
            tracklistunravel{pcc} = track;
        end
        
        % ensemble and time average MSD
        [MSDtot,cnttot,sterrtot] = MSDensemble(tracklistunravel,'overlap',@(k) k);        
        allMSDtot{dc,tc}  = MSDtot;
        allcnttot{dc,tc} = cnttot;
    end
end
if (opt.dodisplay)
    xlabel('time')
    ylabel('unraveled MSD')
    hold off
end
%% get error vals and average them
cmat = jet(length(Dvals));
if (opt.dodisplay == 1)
    figure
end

minct = opt.minct;
Dtrue = 2;
logerrvals = zeros(length(Dvals),ntrial);
pfit = zeros(2,length(Dvals),ntrial);
for dc = 1:length(Dvals)
    D = Dvals(dc);
    
    for tc = 1:ntrial
        cnttot = allcnttot{dc,tc};
        ind = find(cnttot>minct);
        MSDtot = allMSDtot{dc,tc}(ind);
        if (length(MSDtot)<2)
            error('MSD is too short. This should not happen!')
        end
        tvals = (1:length(MSDtot))*opt.timestep;
        
        % try interpolating time logarithmically
        %tinterp = [tvals(1) logspace(log10(tvals(2)),log10(tvals(end-1)),100)];
         tinterp = [logspace(log10(tvals(1)),log10(tvals(end-1)),100)];
        MSDinterp = interp1(tvals,MSDtot,tinterp);
        if opt.power == 1
            p = polyfit(log10(tinterp),log10(MSDinterp),1);
            MSDpower = 10.^p(2)*tinterp.^(p(1));
            pfit(:,dc,tc) = [p(1),10.^p(2)];
        end
        if (opt.dodisplay && tc == 1)
            loglog(tinterp,MSDinterp,'.-','Color',cmat(dc,:))
            hold all
            %if (~opt.power)
                         loglog(tinterp,2*D*tinterp,'--','Color',cmat(dc,:))
            %end
            %             loglog(tinterp,2*Dtrue*tinterp,'k--','LineWidth',2)
            if opt.power == 1
                loglog(tinterp,MSDpower,'k:')
            end
        end
        residuals = MSDinterp - (2*D*tinterp);
        errvals(dc,tc) = sum(residuals.^2);
        
        lMSD = log(MSDinterp);
        allMSDinterp{dc,tc} = MSDinterp;
        logresiduals = lMSD - log(2*D*tinterp);
        logerrvals(dc,tc) = sum(logresiduals.^2);
        
        %ind = 1:length(MSDinterp);
        ind = find(MSDinterp<opt.RsqMSDmax);
        Rsqvals(dc,tc) = 1 - sum(logresiduals(ind).^2)/sum((lMSD(ind)-mean(lMSD(ind))).^2);
        if opt.power == 1
            logpowerresiduals = log(MSDpower) - log(2*D*tinterp);
            logpowererrvals(dc,tc) = sum(logpowerresiduals.^2);
        end
    end
end
if (opt.dodisplay); hold off; end

%% average the errors
avglogerrvals = mean(logerrvals,2);
if (size(logerrvals,2)>1)
    stdlogerrvals = std(logerrvals')';
else
    stdlogerrvals = zeros(size(logerrvals,1),1);
end
stelogerrvals = stdlogerrvals/sqrt(ntrial);
if opt.power == 1
    avglogpowererrvals = mean(logpowererrvals,2);
    if (size(logpowererrvals,2)>1)
        stdlogpowererrvals = std(logpowererrvals')';
    else
        stdlogpowererrvals = zeros(size(logpowererrvals,1),1);
    end
    stelogpowererrvals = stdlogpowererrvals/sqrt(ntrial);
end
if (opt.dodisplay > 1)
    figure
    errorbar(Dvals,avglogerrvals,stelogerrvals)
    hold on
    if (opt.power)
        errorbar(Dvals,avglogpowererrvals,stelogpowererrvals)
    end
    hold off
end
%ylim([0,20])

if (strcmp(opt.errfunc,'Rsq'))
    errvals = 1-Rsqvals;
else
    errvals = avglogerrvals;
end

if logical(opt.mininterp) == 1
    xq = linspace(Dvals(1),Dvals(end),length(Dvals)*opt.mininterp);
    vq = interp1(Dvals,errvals,xq,'spline');
    [~,Dind] = min(vq);
    Dopt = xq(Dind);
    if (opt.dodisplay > 1)
        figure
        plot(Dvals,errvals,'o',xq,vq,'-')
    end
else
    % get the optimum D guess
    [~,Dind] = min(errvals);
    Dopt = Dvals(Dind);
end
end