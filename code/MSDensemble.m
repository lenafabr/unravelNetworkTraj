function [MSDtot,cnttot,sterrtot] = MSDensemble(tracklist,varargin)
% calculate ensemble-averaged MSD for many tracks
% tracklist is a cell array of 1 or 2 dimensional tracks
% output:
% MSDtot = ensemble averaged MSD
% cnttot = number of data points that went into each average
% sterrtot = standard error calculation for each point (not accurate if
% using overlapping intervals)
% assumes all tracks have uniform time-intervals between points

%% overall MSD averaged over many tracks

tracklen = cellfun(@(x) size(x,1),tracklist);
maxlen = max(tracklen);
%
MSDtot = zeros(1,maxlen-1); MSD4tot = MSDtot;
cnttot = zeros(1,maxlen-1);

MSDindiv = cell(length(tracklist),1);
cntindiv = MSDindiv;
MSD4indiv = MSDindiv;

for tc = 1:length(tracklist)
    track = tracklist{tc};
    if (size(track,1)<2) % track too short to calculate displacements
        continue
    end
    [MSDindiv{tc},cntindiv{tc},~,MSD4indiv{tc}] = MSDtimeavg(track,varargin{:});

    MSD = MSDindiv{tc}.*cntindiv{tc};
    MSD4 = MSD4indiv{tc}.*cntindiv{tc};
    goodind = find(~isnan(MSD));
    MSDtot(goodind) = MSDtot(goodind) + MSD(goodind);
    cnttot(goodind) = cnttot(goodind) + cntindiv{tc}(goodind);
    MSD4tot(goodind) = MSD4tot(goodind) + MSD4(goodind);
end
MSDtot = MSDtot./cnttot;
MSD4tot = MSD4tot./cnttot;
sterrtot = sqrt((MSD4tot - MSDtot.^2)./(cnttot-1));
end