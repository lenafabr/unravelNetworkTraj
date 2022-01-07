function [savePos,saveTimes,opt] = randomWalkNetwork2(NT,nPart,nStep,options)

%initialization of parameters
    opt = struct();
    opt.dt = 0.001;                         %step size of the time evolutoin
    opt.saveEvery = 10; %save after each saveEvery steps
    opt.printEvery = 1; % print update every so many steps
    opt.D = 1;                              %difffusion coefficient
    % specify particle starting positions (edge and length along edge for each particle)
    % empty means start uniformly distributed throughout the network
    opt.startpos = []; 
    %copy options if given
    if (exist('options','var'))
        opt = copyStruct(options,opt);
    end
    
    curTime =0;                             %current time inialized to zero
    saveCt = 0;                             %#saves initialized to zero
    stdStep = sqrt(2 * opt.D * opt.dt);     %standard step

%initialization of simulation
if (isempty(opt.startpos))
    %scatter particles over the network initially
    totLen = sum(NT.edgelens);
    cumLen = [0 ; cumsum(NT.edgelens)];
    sampPos = rand(nPart,1) * totLen;
    vals = interp1(cumLen ,0 : NT.nedge,sampPos, 'linear');
    startEdges = floor(vals) + 1;
    startEdgePos = (sampPos - cumLen(startEdges));
    
    pos = [startEdges, startEdgePos];       %position vector for each particle
                                            %2D array
else
    pos = opt.startpos;
end
    
    savePos(:,:,1) = pos;                   %recorded position
    saveCt = 1;
    saveTimes(1) = 0;                       %vector storing recording time 
    
%simulate random walk on the network
    %disp([0 pos(1,:)])
    for sc = 1 : nStep                      %sc for step count
        dx = randn(nPart,1) * stdStep;                        
        for pc = 1:nPart
            ec = pos(pc,1);
            edgeLen = NT.edgelens(ec);
            
            % where we start relative to each node
            x0a = pos(pc,2);
            x0b = edgeLen-pos(pc,2);
            
            % where we end relative to each node
            x1a = x0a+dx(pc);
            x1b = edgeLen - (x0a+dx(pc));
            
            % decide which node to worry about
            [~,whichnode] = min([abs(x0a*x1a), abs(x0b*x1b)]);
            if (whichnode==1) % check for passing 0
                x0 = x0a; x1 = x1a;
                node = NT.edgenodes(ec,1);                
            else % check for passing far end of edge
                x0 = x0b; x1 = x1b;
                node = NT.edgenodes(ec,2);
            end
            deg = NT.degrees(node);
                        
            %[node x0 x1]
            if (x1 < 0) 
                % definitely moved past a node, select edge randomly
                edgeind = randi(deg);
                newEdgeNum = NT.nodeedges(node,edgeind);                    
            else
                % decide whether particle passed the node
                p0 = exp(-x0*x1/(opt.D*opt.dt));
                
                u = rand();
                if (u<p0) % did pass the node, pick edge at random
                    edgeind = randi(deg);
                    newEdgeNum = NT.nodeedges(node,edgeind);                   
                else % did not pass the node, keep on same edge
                    newEdgeNum= ec;
                end
            end
            
            pos(pc,1) = newEdgeNum;
            newlen = NT.edgelens(newEdgeNum);
            if (NT.edgenodes(newEdgeNum,1)==node) % new edge points out from node
                pos(pc,2) = abs(x1);
                if (pos(pc,2)>newlen)
                    error('stepped past end of edge')
                end
            elseif (NT.edgenodes(newEdgeNum,2)==node) % new edge points into node                
                pos(pc,2) = newlen-abs(x1);
                if (pos(pc,2)<0)
                    error('went negative!')                    
                end
            else
                error('something went wrong!')
            end
        end
            
        if (any(pos(:,2)<0))
            error('position went negative!')
        end
        
        if (mod(sc,opt.printEvery)==0)
            % print out progress
            display(sprintf('Step %d. Particle 1 at position %d %f', sc, pos(1,1),pos(1,2)))
        end
            
        curTime = curTime+opt.dt;
        if ((mod(sc, opt.saveEvery)) == 0)  %recording the position of particles
            saveCt = saveCt + 1;            %update saveCt
            savePos(:,:,saveCt) = pos;      %input position into savePos
            % save position in real space (x, y coordinates)
            % ---- fill in here --------
            saveTimes(saveCt) = curTime;
        end
    end
end    
    