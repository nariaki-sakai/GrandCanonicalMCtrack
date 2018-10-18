function computeTracks(dirPos, maxdisp)

    tic;
    listFiles = dir([dirPos '*.txt']);
    nFiles = length(listFiles);
    
    %%
    if nFiles == 0
        disp(['ERROR: No files in ' dirPos]);
    else
        listFiles1 = listFiles(1:nFiles-1);
        listFiles2 = listFiles(2:nFiles);

        dirTrack = [dirPos 'trackID/'];
        if exist(dirTrack,'dir') == 0
            mkdir(dirTrack);
        end
        
        %%% COMPUTE
        disp('COMPUTE');
        tableNext = cell(nFiles,1);
        for indFile = 1:nFiles-1
            %%
            if mod(indFile,1) == 0
                disp([num2str(indFile) ' / ' num2str(nFiles)]);
            end

            pos1 = dlmread([dirPos listFiles1(indFile).name]);
            pos2 = dlmread([dirPos listFiles2(indFile).name]);

            %posAll{indFile} = pos1;

            %%%%%%%%%%%%%%%%%%%%%
            tmpTableNext = computeTracksMain(pos1,pos2,maxdisp);
            %%%%%%%%%%%%%%%%%%%%%
            %Check
            ind1Tracked = find(tmpTableNext~=0);
            deltaPos = abs(pos2(tmpTableNext(ind1Tracked))-pos1(ind1Tracked));
            tempBool = deltaPos > maxdisp;
            tmpTableNext(ind1Tracked(tempBool)) = 0;
            
            tableNext{indFile} = tmpTableNext;
            
            %temp = listFiles1(indFile).name;

        end
        pos1 = dlmread([dirPos listFiles(nFiles).name]);
        np1 = size(pos1,1);
        tableNext{nFiles} = zeros(np1,1);
        
        %%
        disp('CREATE TABLE');
        tableNext1 = [{[]};tableNext(1:end-1)];
        tableNext2 = tableNext;
        dataTracksOut = cell(nFiles,1);
        parfor indFile = 1:nFiles
            tmpTableNext2 = tableNext2{indFile};
            np = size(tmpTableNext2,1);
            tmpTable = zeros(np,2);
            tmpTable(:,2) = tmpTableNext2;
            if indFile == 1
                tmpTable(:,1) = zeros(np,1);
            else
                tmpTableNext1 = tableNext1{indFile};
                [~, numParticles1, numParticles2] = intersect(tmpTableNext1, 1:np);
                tmpTable(numParticles2,1) = numParticles1;
            end        
            dataTracksOut{indFile} = tmpTable;
            %SAVE intermediate files?
            if 0 == 1
                fileNb = num2str(indFile,'%06d');
                fileTrack = ['track_' f 'Hz_' fileNb '.txt'];
                dlmwrite([dirTrack fileTrack],tmpTable,'delimiter','\t');
            end
        end
        %Check intermediate tracking
        if 0 == 1
            %%
            figure(1);
            close(1);
            figure(1);
            hold all;
            indFile = 2+randi(nFiles-2);
            tempTrack = dataTracksOut{indFile};
            tempPos2 = posAll{indFile-1};
            tempPos3 = posAll{indFile  };
            tempPos4 = posAll{indFile+1};
            ind3 = randi(size(tempPos3,1));
            while sum(tempTrack(ind3,:)) == 0
                ind3 = randi(size(tempPos3,1));
            end
            ind2 = tempTrack(ind3,1);
            ind4 = tempTrack(ind3,2);
                        
            plot([real(tempPos2(ind2)) real(tempPos3(ind3)) real(tempPos4(ind4))],[imag(tempPos2(ind2)) imag(tempPos3(ind3)) imag(tempPos4(ind4))],'k-','LineWidth',5);
            plot(real(tempPos2),imag(tempPos2),'r.');
            plot(real(tempPos3),imag(tempPos3),'g.');
            plot(real(tempPos4),imag(tempPos4),'b.');
            axis equal;
            
        end
        
        
        
        %% SAVE
        disp('SAVE');
        parfor indFile = 1:nFiles
            fileNb = num2str(indFile,'%06d');
            trackPath = ['track_' f 'Hz_' fileNb '.txt'];
            dlmwrite([dirTrack trackPath],dataTracksOut{indFile},'delimiter','\t');
        end
        
    end
    disp('END TRACK');
    toc;
    
end
























