function [pos, d] = initialPosGuess(img3D,method)
    %%
    if method == 'localMax'
        %%
        sizeImg = size(img3D);
        x = 1:sizeImg(2);
        y = 1:sizeImg(1);
        z = 1:sizeImg(3);
        [meshX,meshY,meshZ] = meshgrid(x,y,z);
        
        binaryImg3D = 0*img3D;
        maxImg = max(img3D(:));
        binaryImg3D(img3D(:) > maxImg/4) = 1;
        BW = imregionalmax(binaryImg3D);
        CC = bwconncomp(BW);
        
        N = CC.NumObjects;
        pos = zeros(N,3);
        d = zeros(N,1);
        for indP = 1:N
            %%
            r = [meshX(CC.PixelIdxList{indP}) meshY(CC.PixelIdxList{indP}) meshZ(CC.PixelIdxList{indP})];
            pos(indP,:) = mean(r,1);
            d(indP)     = 2*sqrt(mean(dist(r,pos(indP,:)).^2));
        end
        
    elseif method == 'colloid'
        disp('ERROR: method colloid is not available right now. Please do it yourself');
    else
        disp('ERROR: method for initial guess has wrong attribute');
        pos = nan;
        return;
    end

end