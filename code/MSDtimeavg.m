function [MSD,cnt,sterr,MSD4] = MSDtimeavg(track,varargin)
% MSD for a single track; can be 1D or 2D; time average only
% IMPORTANT: assumes uniformly spaced time intervals
% track(:,1:2) has x, y coordinates
% outputs:
% MSD = mean square displacements for increasing time separations
% cnt = counts of data that went into each point
% sterr = standard error of each MSD calculaton (not accurate for
% overlapping intervals since assumes them independent)
% MSD4 = mean displacements to the 4th power

% -----
% optional arguments
% ------
% overlap = function of k giving the separation between intervals; default
% is 1 (fully overlapping intervals);
% if overlap<0 then take first interval only, no time averaging

overlap = @(k) 1;

for vc = 1:2:length(varargin)
    switch (varargin{vc})
        case('overlap')
            overlap = varargin{vc+1};
    end
end


MSD = zeros(1,length(track)-1);
sterr = MSD;
cnt = MSD;

for dc = 1:length(track)-1
    stp = overlap(dc);
    
    if (stp<0) % no time averaging
         if (size(track,2)>1)
            nd2 = (track(dc+1,1:2)-track(1,1:2)).^2;
            add = sum(nd2,2);
        else
            add = (track(dc+1)-track(1)).^2;
        end
    else
        if (size(track,2)>1)
            nd2 = (track(dc+1:stp:end,1:2)-track(1:stp:end-dc,1:2)).^2;
            add = sum(nd2,2);
        else
            add = (track(dc+1:stp:end)-track(1:stp:end-dc)).^2;
        end
    end
    
    MSD(dc) = MSD(dc)+sum(add);
    sterr(dc) = sterr(dc)+sum(add.^2);
    cnt(dc) = cnt(dc)+length(add);
end
MSD = MSD./cnt;
MSD4 = sterr./cnt;
sterr = sqrt((sterr./cnt - MSD.^2)./(cnt-1));
