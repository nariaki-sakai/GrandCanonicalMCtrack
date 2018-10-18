function [meshXYZ, newSimImg] = energyVarAddRemove(newPos,imgSize,d,S)

    rMax = max(S(1,:));
    indXMin = round(newPos(1)-rMax*d);
    indXMax = round(newPos(1)+rMax*d);
    indYMin = round(newPos(2)-rMax*d);
    indYMax = round(newPos(2)+rMax*d);
    indZMin = round(newPos(3)-rMax*d);
    indZMax = round(newPos(3)+rMax*d);
    indXMin = min(indXMin,0);
    indXMax = max(indXMax,imgSize(1));
    indYMin = min(indYMin,0);
    indYMax = max(indYMax,imgSize(2));
    indZMin = min(indZMin,0);
    indZMax = max(indZMax,imgSize(3));
    
    [X,Y,Z] = meshgrid(indXMin:indXMax,indYMin:indYMax,indZMin,indZMax);
    meshXYZ = {X,Y,Z};
    
    r = sqrt(X.^2+Y.^2+Z.^2)/d;
    newSimImg = interp1(S(1,:),S(2,:),r);
    
    
end





