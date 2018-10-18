function [dataTracksOut, pos3New, indNewPoint] = computeTracksConnect(dataTracks,dataPos)
    %%
    pxl2mm = 0.207;
    R = 2/pxl2mm;
    
    track2 = dataTracks{1};
    track3 = dataTracks{2};
    track4 = dataTracks{3};
    
    ind2Lost  = find(track2(:,2) == 0 & track2(:,1) ~= 0);
    ind4Appeared = find(track4(:,1) == 0 & track4(:,2) ~= 0);

    if isempty(ind2Lost) || isempty(ind4Appeared)
        dataTracksOut = dataTracks;
        pos3New = dataPos{3};
        indNewPoint = [];
    else
        ind1Lost = track2(ind2Lost,1);
        ind5Appeared = track4(ind4Appeared,2);

        pos1 = dataPos{1};
        pos2 = dataPos{2};
        pos3 = dataPos{3};
        pos4 = dataPos{4};
        pos5 = dataPos{5};

        pos1Lost = pos1(ind1Lost);
        pos2Lost = pos2(ind2Lost);
        pos4Lost = pos4(ind4Appeared);
        pos5Lost = pos5(ind5Appeared);
        deltaPos2 = (pos2Lost-pos1Lost);
        deltaPos4 = (pos5Lost-pos4Lost);

        pos3Lost1 = pos2Lost+deltaPos2;
        pos3Lost2 = pos4Lost-deltaPos4;
        np3Lost1 = size(pos3Lost1,1);
        np3Lost2 = size(pos3Lost2,1);
        dat = [real(pos3Lost1) imag(pos3Lost1) ones(np3Lost1,1);
               real(pos3Lost2) imag(pos3Lost2) 2*ones(np3Lost2,1)];
        param = struct('mem',0,'dim',2,'good',0,'quiet',1);
        maxdisp = 8;
        trackOut = mytrack(dat,maxdisp,param);
        posTrackOut = trackOut(:,1)+1i*trackOut(:,2);
        indTrackOut = trackOut(:,3);

        %REMOVE TOO LARGE DISPLACEMENTS
        maxDisp = 15*R;
        for ind=1:length(indTrackOut)
            if indTrackOut(ind) == 1
                pos1 = posTrackOut(ind);
                pos2 = posTrackOut(ind+1);
                if abs(pos2-pos1) > maxDisp
                    indTrackOut(ind:ind+1) = [];
                    indTrackOut = [1; indTrackOut; 2];
                    posTrackOut(ind:ind+1) = [];
                    posTrackOut = [pos1; posTrackOut; pos2];
                end
            end
        end
        
        %CREATE NEW POINTS
        indTracked1 = find((diff(indTrackOut) ~= 0) & (indTrackOut(1:end-1) == 1));
        indTracked2 = indTracked1 + 1;
        tempPos3New = (posTrackOut(indTracked1)+posTrackOut(indTracked2))/2;
        np3Tracked = length(tempPos3New);
        np3 = size(pos3,1);
        track3New = [track3; ones(np3Tracked,2)];
        pos3New = [pos3; tempPos3New];
        indNewPoint = np3+1:np3+np3Tracked;
        
        %CONNECT TO OTHERS
        for ind3 = 1:np3Tracked
            [~,ind2] = min(abs(pos3Lost1 - tempPos3New(ind3)));
            track2(ind2Lost(ind2),2) = np3+ind3;
            [~,ind4] = min(abs(pos3Lost2 - tempPos3New(ind3)));
            track4(ind4Appeared(ind4),1) = np3+ind3;
            track3New(np3+ind3,:) = [ind2Lost(ind2) ind4Appeared(ind4)];
        end
        dataTracksOut = {track2; track3New; track4};
        if size(pos3New,1) ~= size(track3New,1)
            disp('WARNING: sizes don''t match');
        end
        
        %Check
        if 0 == 1
            %%
            figure(1);
            close(1);
            figure(1);
            hold all;
            indP3 = randi(np3+np3Tracked);
            p2 = pos2(track3New(indP3,1));
            p3 = pos3New(indP3);
            p4 = pos4(track3New(indP3,2));

            plot([real(p2) real(p3) real(p4)],[imag(p2) imag(p3) imag(p4)],'k-','LineWidth',2);
            markerSize = 5;
            plot(real(dataPos{1}),imag(dataPos{1}),'.','Color',0.5*[1 1 1],'Markersize',markerSize);
            plot(real(dataPos{2}),imag(dataPos{2}),'r.','Markersize',markerSize);
            plot(real(dataPos{3}),imag(dataPos{3}),'g.','Markersize',markerSize);
            plot(real(dataPos{4}),imag(dataPos{4}),'b.','Markersize',markerSize);
            plot(real(dataPos{5}),imag(dataPos{5}),'.','Color',0.5*[1 1 1],'Markersize',markerSize);
            plot(real(pos1Lost),imag(pos1Lost),'ko');
            plot(real(pos2Lost),imag(pos2Lost),'ro');
            plot(real(pos2Lost+deltaPos2),imag(pos2Lost+deltaPos2),'r+');
            plot(real(pos4Lost-deltaPos4),imag(pos4Lost-deltaPos4),'b+');
            plot(real(pos4Lost),imag(pos4Lost),'bo');
            plot(real(pos5Lost),imag(pos5Lost),'ko');
            axis equal;
        end
    end
end






















