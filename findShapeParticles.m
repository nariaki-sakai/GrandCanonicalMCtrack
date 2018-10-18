function [r, S] = findShapeParticles(img3D,pos,d,method)

    if strcmp(method,'flat')
        S = zeros(100,100);
        meanD = mean(d);
        listD = linspace(meanD - meanD/2, meanD + meanD/2);
        r = linspace(0,2);
        
        for indDiam = 1:length(listD)
            r0 = listD(indDiam)/2;
            sigmaShape = 0.276/r0;
            S(indDiam,:) = r/2;
            S(indDiam,:) = 1/2*( erf((1-r)/(sqrt(2)*sigmaShape)) + erf((1+r)/(sqrt(2)*sigmaShape)) )...
                     - 1/sqrt(2*pi)*sigmaShape./r.*( exp(-(r-1).^2/(2*sigmaShape^2)) - exp(-(r+1).^2/(2*sigmaShape^2)) );
        end
        
             
             
    elseif strcmp(method,'find')
        
        disp('ERROR: this method is not available');
        return;
        
        imgPos = 0*img3D;
        N = size(pos,1);
        indi = ceil(pos(:,2));
        indj = ceil(pos(:,1));
        indk = ceil(pos(:,3));
        for indP = 1:N
            imgPos(indi(indP),indj(indP),indk(indP)) = imgPos(indi(indP),indj(indP),indk(indP)) + 1;
        end
        if sum(imgPos(:)) ~= N
            disp('WARNING: overlap of particles in pos');
        end

        S = ifft(fft(img3D)./fft(imgPos));

    else
        disp('ERROR: option for finding the shape of particles has wrong attribute');
        return;
    end
    
end
















