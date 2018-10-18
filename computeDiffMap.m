function diffMap = computeDiffMap(img3D,simImg,method)

    if strcmp(method,'MSE')
        diffMap = img3D - simImg;
    elseif strcmp(method,'similarity')
        disp('ERROR: similarity not curretly available');
    end

end













