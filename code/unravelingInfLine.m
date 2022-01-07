function unraveltraj = unravelingInfLine(NT,posinfo,dt,D,options)
% NT = network object
% posinfo = [edge index, position along edge in real length units], for a
% single trajectory
% dt = time interval for each step
% NT must have an edgeedge structure

opt = struct();

if (exist('options','var'))
    opt = copyStruct(options,opt);
end

nstep = size(posinfo,2);

unraveltraj = zeros(nstep,1);

edgedir1 = 1; 

% go through step by step
for sc = 1:nstep-1    
    edge0 = posinfo(1,sc); % starting edge
    edgedir0 = edgedir1;
    
    n1 = NT.edgenodes(edge0,1); n2 = NT.edgenodes(edge0,2);
    edge1 = posinfo(1,sc+1); % ending edge
    
    if (edge1 ~= edge0)
        % find which node it jumped over                        
        whichnode = 0;       
        for cc = 1:(NT.degrees(n1)+NT.degrees(n2))
            if (edge1 == NT.edgeedges(edge0,2,cc))
                whichnode = NT.edgeedges(edge0,1,cc);
                break
            end
        end        
        if (whichnode==0)
            error('Jumped onto non-connected edge!')
        end
        nj = NT.edgenodes(edge0,whichnode);% index of node jumped over
        
        if (whichnode == 1)
            x0 = posinfo(2,sc);  
            
             if (nj == NT.edgenodes(edge1,1))
                % new edge oriented out from jump node
                x1 = posinfo(2,sc+1);
                edgedir1 = -1;
            elseif (nj == NT.edgenodes(edge1,2))
                % new edge oriented into jump node
                edgedir1 = 1;
                x1 = NT.edgelens(edge1)-posinfo(2,sc+1);
            else
                error('nj does not match to new edge')
             end
            
        elseif (whichnode==2)
            x0 = NT.edgelens(edge0) - posinfo(2,sc);  
            
            if (nj == NT.edgenodes(edge1,1))
                % new edge oriented out from jump node
                x1 = posinfo(2,sc+1);
                edgedir1 = 1;
            elseif (nj == NT.edgenodes(edge1,2))
                % new edge oriented into jump node
                edgedir1 = -1;
                x1 = NT.edgelens(edge1)-posinfo(2,sc+1);
            else
                error('nj does not match to new edge')
            end
            
        else
            error('something bizarre happened')
        end       
        
        % probability we jumped over node in infinite line case
        pjump = 0.5;              
    else
        % particle on network did not leave the edge
        edgedir1 = edgedir0;
        
        % decide which node to worry about
        % this assumes it can pass over at most 1 node in this step
        x0a = posinfo(2,sc);
        x0b = NT.edgelens(edge0)-posinfo(2,sc);
        x1a = posinfo(2,sc+1);
        x1b = NT.edgelens(edge0)-posinfo(2,sc+1);
        
        [~,whichnode] = min([x0a*x1a, x0b*x1b]); 
        if (whichnode == 1)
            x0 = x0a; x1 = x1a;
        else
            x0 = x0b; x1 = x1b;
        end
        nj = NT.edgenodes(edge0,whichnode);
        
        pjump = 1/(2 + NT.degrees(nj)*(exp(x0*x1/D/dt)-1));
    end
    
    % decide whether to step + or - (jump over node or not)
    u = rand();
    didjump = (u<pjump);
    if (didjump)
        dx = -(x0+x1)*edgedir0;
    else % do not jump over the node
        dx = (-x0+x1)*edgedir0;
    end
    if (whichnode==2); dx = -dx; end
    unraveltraj(sc+1) = unraveltraj(sc)+dx;
    
end


end