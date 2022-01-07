function tracklist = loadTrackList(filename)

data = dlmread(filename,',',2,9);


%% break into list of tracks
iddiff = diff(data(:,1));
breakind = find(iddiff>0);

tracklist = breakTrack(data(:,3:5),breakind);

ntrack = length(tracklist);
for tc = 1:ntrack
    track = tracklist{tc};
    tracklist{tc} = [track(:,2:3) track(:,1)];
end

end