function tmpTableNext = computeTracksMain(pos1,pos2,maxdisp)

% % %     pxl2mm = 0.2070;
% % %     R = 2/pxl2mm;
    
    
    param = struct('mem',0,'dim',size(pos1,2),'good',0,'quiet',0);
    np1 = size(pos1,1);
    np2 = size(pos2,1);

    %PASS 1
    dat = [pos1 1*ones(np1,1);
           pos2 2*ones(np2,1)];
    trackOut = mytrack(dat,maxdisp,param);
    posTrackOut = trackOut(:,1:end-1);
    indTrackOut = trackOut(:,end);

    %%% COLLECTING TRACK 1
    tmpTableNext = zeros(np1,1);
    idTrack1=find(indTrackOut==1);
    idTrack2=find(indTrackOut==2);
    idPos1 = zeros(np1,2);%Index in indTrackOut of the particle pos1(k)
    idPos2 = zeros(np2,2);%Index in indTrackOut of the particle pos2(k)
    idPos1(:,1) = (1:np1)';
    idPos2(:,1) = (1:np2)';
    for ind1 = 1:np1
        [~,ind] = min(dist(pos1(ind1) - posTrackOut(idTrack1)));
        idPos1(ind1,2) = idTrack1(ind);
    end
    for ind2 = 1:np2
        [~,ind] = min(dist(pos2(ind2) - posTrackOut(idTrack2)));
        idPos2(ind2,2) = idTrack2(ind);
    end
    %Collect and find non tracked particles
    ind1Lost = [];
    for ind1 = 1:np1
        indNext = idPos1(ind1,2)+1;
        if indTrackOut(indNext)==1
            ind1Lost = [ind1Lost ind1];
        else
            tmpTableNext(ind1) = idPos2(indNext == idPos2(:,2),1);
        end
    end
    ind2Lost = [];
    for ind2 = 1:np2
        indBefore = idPos2(ind2,2)-1;
        if indTrackOut(indBefore)==2
            ind2Lost = [ind2Lost ind2];
        end
    end
    %check
    if 0 == 1
        %%
        figure(1);
        close(1);
        figure(1);
        plot(real(pos1),imag(pos1),'r.');
        hold all;
        plot(real(pos2),imag(pos2),'b.');

        ind1 = find(tmpTableNext~=0);
        ind2 = tmpTableNext(ind1);
        traj = [pos1(ind1) pos2(ind2)];
        for indTraj = 1:size(traj,1)
            plot(real(traj(indTraj,:)),imag(traj(indTraj,:)),'k-');
        end
    end

    if 0 == 1
        %%
        figure(2);
        close(2);
        figure(2);
        hold all;
        plot(real(pos1),imag(pos1),'.','Color',0.5*[1 0 0]);
        plot(real(pos2),imag(pos2),'.','Color',0.5*[0 0 1]);
        plot(real(pos1(ind1Lost)),imag(pos1(ind1Lost)),'ro');
        plot(real(pos2(ind2Lost)),imag(pos2(ind2Lost)),'bo');
        plot(real(pos1New),imag(pos1New),'r+');
        plot(real(pos2New),imag(pos2New),'b+');
        axis equal;

    end

    if isempty(ind1Lost) || isempty(ind2Lost)
    else
        %DEFINE LOCAL DISPLACEMENT FIELD AROUND NON TRACKED PARTICLES

        pos1New = pos1(ind1Lost);
        pos2New = pos2(ind2Lost);

        %% PASS 2
        dat = [pos1New 1*ones(length(pos1New),1);
               pos2New 2*ones(length(pos2New),1)];

        trackOut = mytrack(dat,maxdisp,param);
        posTrackOut = trackOut(:,1:end-1);
        indTrackOut = trackOut(:,end);
        
        %%% COLLECTING TRACK 2
        np1 = length(ind1Lost);
        np2 = length(ind2Lost);
        idTrack1=find(indTrackOut==1);
        idTrack2=find(indTrackOut==2);
        idPos1 = zeros(np1,2);%Index in indTrackOut of the particle pos1(k)
        idPos2 = zeros(np2,2);%Index in indTrackOut of the particle pos2(k)
        idPos1(:,1) = (1:np1)';
        idPos2(:,1) = (1:np2)';
        for ind1 = 1:np1
            [~,ind] = min(dist(pos1(ind1Lost(ind1))+localDisplacement(ind1) - posTrackOut(idTrack1)));
            idPos1(ind1,2) = idTrack1(ind);
        end
        for ind2 = 1:np2
            [~,ind] = min(dist(pos2(ind2Lost(ind2)) - posTrackOut(idTrack2)));
            idPos2(ind2,2) = idTrack2(ind);
        end
        %Collect
        for ind1 = 1:np1
            indNext = idPos1(ind1,2)+1;
            if indTrackOut(indNext)==1
            else
                tmpTableNext(ind1Lost(ind1)) = ind2Lost(idPos2(indNext == idPos2(:,2),1));
            end
        end
    end

end














