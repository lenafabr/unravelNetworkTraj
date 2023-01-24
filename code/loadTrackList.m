function tracklist = loadTrackList(filename,frametime)
% optional: if frametime=true, read in the frame as well as the actual time
% columns 1,2 = x,y
% column 3 = time
% column 4 = frame (optional)

%data = dlmread(filename,',',2,9);
datatable = readtable(filename);

varnames = datatable.Properties.VariableNames;

% find the columns corresponding to Traj id, x, y, time
xcol = find(startsWith(varnames,'x','IgnoreCase',true));
ycol = find(startsWith(varnames,'y','IgnoreCase',true));
tcol = find(startsWith(varnames,'time','IgnoreCase',true));
fcol = find(startsWith(varnames,'frame','IgnoreCase',true));
trajcol = find(startsWith(varnames,'traj','IgnoreCase',true));

trajdata = table2array(datatable(:,trajcol));

if (~exist('frametime','var'))
    frametime = false;
end

if (frametime)
    txydata = table2array(datatable(:,[tcol,xcol,ycol,fcol]));
else
    txydata = table2array(datatable(:,[tcol,xcol,ycol]));
end

%% break into list of tracks
iddiff = diff(trajdata);
breakind = find(iddiff>0);

tracklist = breakTrack(txydata,breakind);

ntrack = length(tracklist);
for tc = 1:ntrack
    track = tracklist{tc};
    if (frametime)
       tracklist{tc} = [track(:,2:3) track(:,1) track(:,4)];
    else
        tracklist{tc} = [track(:,2:3) track(:,1)];
    end
end

end