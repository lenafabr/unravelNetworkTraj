function [tracklist] = SavePos2Traj2(NT,savePos)
% This function converts from coordinates in terms of edge index and
% position along edge to real-space coordianates

% Input:
% savePos should be 3d matrix, with dimensions: particles, (info), time index
% savePos(pc,1,tc) = edge particle pc is on at time tc
% savePos(pc,2,tc) = how far along the edge it is on

% Output:
% tracklist is a cell of matrix with timesteps against R2 position
% each cell represents a particle
%%
    [nPart, ~, nCount] = size(savePos);
    tracklist = cellmat(nPart, 1, nCount, NT.dim);

    edgeNum = squeeze(savePos(:, 1, :));
    edgePos = squeeze(savePos(:, 2, :));
    uniqueNum = unique(edgeNum);
    nList = 1 : nPart;
%%
    for i = 1 : length(uniqueNum)
       %%
        j = uniqueNum(i);
        if (nPart == 1)
            occur = nList(any(edgeNum == j, 1));
        else
            occur = nList(any(edgeNum == j, 2));
        end
        nIndex = cell(length(occur), 1);
        nPos = zeros(nnz(edgeNum == j), 1);
        n = 1;
        for k = 1 : length(occur)
            if (nPart == 1)
                nIndex{k} = edgeNum == j;
                nPos(n : n + nnz(nIndex{k}) - 1) = edgePos(nIndex{k});
            else
                nIndex{k} = edgeNum(occur(k), :) == j;
                nPos(n : n + nnz(nIndex{k}) - 1) = edgePos(occur(k), nIndex{k});
            end
            n = n + nnz(nIndex{k});
        end
        realPos = interp1(NT.cumedgelen{j}, NT.edgepath{j}, nPos);
        n = 1;
        for k = 1 : length(occur)
            tracklist{occur(k)}(nIndex{k}, :) = realPos(n : n + nnz(nIndex{k}) - 1, :);
            n = n + nnz(nIndex{k});
        end
    end
    
    %% add a third column to each track corresponding to the frame number
    for tc = 1:length(tracklist)
        tracklist{tc}(:,3) = (1:size(savePos,3))';
    end
        
end
