function pos = GrandCanMCtrack(img3D,T,mu,opt)

    %SET OPTIONS
    if ~exist('opt','var')
    % third parameter does not exist, so default it to something
        opt.initGuess     = 'localMax';
        opt.shapePart     = 'flat';
        opt.diffImgMethod = 'MSE';
        opt.quiet         = 'true';
        opt.stopTimeStep           = 10;
        opt.ratioDispChangeNbPart  = 1/2;
        opt.stopCriteriaFreeEnergy = 1/10;%Stop if fluctuations on free energy is
                                          %continuously less than T/10
                                          %during N*stopTimeStep (rejected
                                          %MC steps are considered in this
                                          %case)
    end
    
    %% INITIALIZATION
    
    imgSize = size(img3D);
    V = prod(imgSize);
    
    %FIND LOCAL MAXIMA - GUESS FOR INITIAL POSITIONS
    method = opt.initGuess;
    [pos, d] = initialPosGuess(img3D,method);
    N = size(pos,1);
    disp(['INITIAL GUESS: ' num2str(N) ' particles detected']);
    
    %FIND SHAPE OF PARTICLES S(r)
    method = opt.shapePart;
    S = findShapeParticles(img3D,pos,d,method);
    
    %Pixels intensity difference Map
    simImg = simulatedImg(pos,imgSize,d,S);
    method = opt.diffImgMethod;
    diffMap = computeDiffMap(img3D,simImg,method);
    
    %test
    if 0 == 1
        %%
        h1 = figure;
        hold all;
        setFigureSize;
        x = 1:sizeImg(1);
        y = 1:sizeImg(2);
        z = 1:sizeImg(3);
        %2D projection of 3D image
        projImg = max(img3D,[],3);
        imagesc(x,y,projImg);
        plot(pos(:,1),pos(:,2),'+');
        %%
        h2 = figure;
        hold all;
        setFigureSize;
        proj3DdiffMap = sum(diffMap,3);
        imagesc(proj3DdiffMap);
        plot(pos(:,1),pos(:,2),'+');
        
        pause;
        close(h1);
        close(h2);
        
    end
    
    %% MONTE CARLO LOOP
    ratioDispChangeNbPart = opt.ratioDispChangeNbPart;
    
    continuouslyUnderStopCriteria = 0;
    acceptedMCstep                = 0;
    totalMCstep                   = 0;
    timeSerieDeltaF               = nan*ones(opt.stopTimeStep*N);
    
    while continuouslyUnderStopCriteria < opt.stopTimeStep*N
        
        %% FREE ENERGY VARIATION
        p = rand;
        %ADD PARTICLE
        if p < ratioDispChangeNbPart/2
            
            indPos  = find(max(diffMap));%Add where diffMap is max
            newPos  = [indPos(2) indPos(1) indPos(3)];
            newDiam = mean(d);
            [meshXYZ, newSimImg] = energyVarChangeN(newPos,imgSize,newDiam,S);
            DeltaE  = sum(newSimImg(:));
            DeltaF  = DeltaE/T - mu/T - log(V/(N+1));
            
        %REMOVE PARTICLE
        elseif p < ratioDispChangeNbPart
            
            indPos = find(min(diffMap));%Remove where diffMap is min
            indPos = [indPos(2) indPos(1) indPos(3)];
            indPos = min(dist(pos,indPos));
            currentPos = pos(indPos,:);
            
            [meshXYZ, newSimImg] = energyVarChangeN(currentPos,imgSize,d(indPos),S);
            DeltaE = -sum(newSimImg(:));
            DeltaF = DeltaE/T + mu/T - log(N/V);
            
        %PICK ONE PARTICLE AND MOVE
        else
            indPos = rand(N,1);%pick one particle
            %change diameter of particles: over uniform distribution
            %centered around oldDiam and window size is 2*oldDiam*ampDiam
            oldDiam = d(indPos);
            ampDiam = 1;
            newDiam = oldDiam*(ampDiam*(rand-1/2) + 1);
            %Uniform prob distribution
            %with max displacement equal to one diamater of particles
            deltar  = newDiam*rand;    
            theta   = 2*pi*rand;
            phi     = pi*rand;
            %displacement in spherical coordinates
            deltaPos = deltar*[cos(theta)*sin(phi) sin(theta)*sin(phi) cos(phi)];
            %new position
            oldPos = pos(indPos,:);
            newPos = oldPos + deltaPos;
            
            %Free energy variation
            [meshXYZ, newSimImg] = energyVarMove(oldPos,newPos,imsSize,oldDiam,newDiam,S);
            DeltaF = sum(newSimImg(:));
        end
        
        %% ACCEPT/REJECT
        if rand < exp(min(0,-DeltaF/T))
            if p < ratioDispChangeNbPart/2
                pos         = [pos; newPos];
            elseif p < ratioDispChangeNbPart
                pos(indP,:) = [];
                d(indP)     = [];
            else
                pos(indP,:) = newPos;
            end
            simImg(meshXYZ{2}(:),meshXYZ{1}(:),meshXYZ{3}(:)) = newSimImg(:);
            diffMap = computeDiffMap(img3D,simImg,method);

            timeSerieDeltaF(1) = [];
            timeSerieDeltaF = [timeSerieDeltaF; DeltaF];
            if nanmax(timeSerieDeltaF) < T*opt.stopCriteriaFreeEnergy
                continuouslyUnderStopCriteria = continuouslyUnderStopCriteria + 1;
            end
            
            acceptedMCstep = acceptedMCstep + 1;
        else
            continuouslyUnderStopCriteria = continuouslyUnderStopCriteria + 1;
        end
            
        %% END
        totalMCstep = totalMCstep + 1;
    end

end