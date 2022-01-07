function tracklist = breakTrack(track,breakind,minlen)
% break a single track into a cell list of tracks
% after the given break indices

if (isempty(breakind))
    tracklist = {track};
else
    
    tc = 1;
    tracklist = {};
    tracklist{tc} = track(1:breakind(1),:);
    
    for bc = 1:length(breakind)-1
        tc= tc+1;
        tracklist{tc} = track(breakind(bc)+1:breakind(bc+1),:);
    end
    tc = tc+1;
    tracklist{tc} = track(breakind(end)+1:end,:);
end

if (exist('minlen','var'))
    tracklen = cellfun(@(x) size(x,1), tracklist);
    
    ind = find(tracklen>=minlen);
    tracklist = tracklist(ind);
end


end