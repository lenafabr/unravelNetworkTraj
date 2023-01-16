function tracklist = loadTrackList(filename)

%data = dlmread(filename,',',2,9);
datatable = readtable(filename);

varnames = datatable.Properties.VariableNames;

% find the columns corresponding to Traj id, x, y, time
xcol = find(startsWith(varnames,'x','IgnoreCase',true));
ycol = find(startsWith(varnames,'y','IgnoreCase',true));
tcol = find(startsWith(varnames,'time','IgnoreCase',true));
trajcol = find(startsWith(varnames,'traj','IgnoreCase',true));

trajdata = table2array(datatable(:,trajcol));
txydata = table2array(datatable(:,[tcol,xcol,ycol]));

%% break into list of tracks
iddiff = diff(trajdata);
breakind = find(iddiff>0);

tracklist = breakTrack(txydata,breakind);

ntrack = length(tracklist);
for tc = 1:ntrack
    track = tracklist{tc};
    tracklist{tc} = [track(:,2:3) track(:,1)];
end

end