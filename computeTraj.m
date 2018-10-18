function [traj, sizeTraj] = computeTraj(root,f)
    
    currentDir = [root f 'Hz/'];
    dirTrack = [currentDir 'track_' f 'Hz/'];
    dirPos = [currentDir 'data_tracked_positions_' f 'Hz/'];
    listFileTrack = dir([dirTrack '*.txt']);
    listFilePos = dir([dirPos '*.txt']);
    nFiles = length(listFilePos);
    
% % %     centerDrum = dlmread([currentDir 'center_drum_' f 'Hz.txt']);
% % %     centerRotation = dlmread([currentDir 'center_rotation_' f 'Hz.txt']);
% % %     centerDrum = centerDrum(1) + 1i*centerDrum(2);
% % %     centerRotation = centerRotation(1) + 1i*centerRotation(2);
    
    %%
    disp('COMPUTE TRACK ID');

    dataTrack = dlmread([dirTrack listFileTrack(1).name]);    
    np = size(dataTrack,1);
    ntracks = sum(dataTrack(:,2)~=0);
    trackId = zeros(np,1);
    trackId(dataTrack(:,2)~=0)=1:ntracks;
    tracksT = cell(nFiles,1);
    tracksT{1} = trackId;

    for indFile=2:nFiles
        dataTrackNew = dlmread([dirTrack listFileTrack(indFile).name]);  
        trackIdNew = zeros(size(dataTrackNew,1),1);
        trackIdNew(dataTrack(dataTrack(:,2)~=0,2)) = trackId(dataTrack(:,2)~=0);
        idnew = find(dataTrackNew(:,2)&(~trackIdNew));
        trackIdNew(idnew)=ntracks+1:ntracks+length(idnew);
        tracksT{indFile} = trackIdNew;
        ntracks = ntracks + length(idnew);
        dataTrack = dataTrackNew;
        trackId = trackIdNew;
    end;

    %% COMPUTE TRAJECTORIES

    disp('COMPUTE TRAJECTORIES');

    traj = cell(ntracks,1);
    tic;
    
    for indFile=1:nFiles
        if mod(indFile, 100) == 0
            if length(num2str(indFile)) < 4
                disp(['ind_img =  ' num2str(indFile) ' / ' num2str(nFiles)]);
            else
                disp(['ind_img = ' num2str(indFile) ' / ' num2str(nFiles)]);
            end
        end
        pos1 = dlmread([dirPos listFilePos(indFile).name]);
        np1 = length(pos1);

        temp_tracksT = tracksT{indFile};
        %temp_pos = 
        parfor j=1:ntracks
            idt = find(temp_tracksT ==j);
            if(~isempty(idt))
                traj{j} = [traj{j}; pos1(idt,1:2) indFile];
            end;
        end;
    end;
    
    sizeTraj = zeros(length(traj),1);
    for ind = 1:length(traj);
        sizeTraj(ind) = size(traj{ind},1);
    end
    [sizeTraj,ind] = sort(sizeTraj);
    traj = flipud(traj(ind));
    
    %
    if 1 == 1
        save([currentDir 'data_trajectory_' f 'Hz.mat'],'traj','sizeTraj');
    end
    
end





























