function [meshXYZ, newSimImg] = energyVarMove(oldPos,newPos,imgSize,oldDiam,newDiam,S)

    rMax = max(S(1,:));
    indXMinAdd = round(newPos(1)-rMax*newDiam);
    indXMaxAdd = round(newPos(1)+rMax*newDiam);
    indYMinAdd = round(newPos(2)-rMax*newDiam);
    indYMaxAdd = round(newPos(2)+rMax*newDiam);
    indZMinAdd = round(newPos(3)-rMax*newDiam);
    indZMaxAdd = round(newPos(3)+rMax*newDiam);
    indXMinAdd = min(indXMinAdd,0);
    indXMaxAdd = max(indXMaxAdd,imgSize(1));
    indYMinAdd = min(indYMinAdd,0);
    indYMaxAdd = max(indYMaxAdd,imgSize(2));
    indZMinAdd = min(indZMinAdd,0);
    indZMaxAdd = max(indZMaxAdd,imgSize(3));
    
    indXMinRem = round(newPos(1)-rMax*oldDiam);
    indXMaxRem = round(newPos(1)+rMax*oldDiam);
    indYMinRem = round(newPos(2)-rMax*oldDiam);
    indYMaxRem = round(newPos(2)+rMax*oldDiam);
    indZMinRem = round(newPos(3)-rMax*oldDiam);
    indZMaxRem = round(newPos(3)+rMax*oldDiam);
    indXMinRem = min(indXMinAdd,0);
    indXMaxRem = max(indXMaxAdd,imgSize(1));
    indYMinRem = min(indYMinAdd,0);
    indYMaxRem = max(indYMaxRem,imgSize(2));
    indZMinRem = min(indZMinAdd,0);
    indZMaxRem = max(indZMaxAdd,imgSize(3));
    
    indXMin = min(indXMinAdd,indXMinRem);
    indXMax = max(indXMaxAdd,indXMaxRem);
    indYMin = min(indYMinAdd,indYMinRem);
    indYMax = max(indYMaxAdd,indYMaxRem);
    indZMin = min(indZMinAdd,indZMinRem);
    indZMax = max(indZMaxAdd,indZMaxRem);
    
    [X,Y,Z] = meshgrid(indXMin:indXMax,indYMin:indYMax,indZMin:indZMax);
    meshXYZ = {X,Y,Z};
    
    rAdd = sqrt((X-newPos(1)).^2+(Y-newPos(2)).^2+(Z-newPos(3)).^2)/oldDiam;
    rRem = sqrt((X-oldPos(1)).^2+(Y-oldPos(2)).^2+(Z-oldPos(3)).^2)/oldDiam;
    newSimImg = interp1(S(1,:),S(2,:),rAdd) - interp1(S(1,:),S(2,:),rRem);
    
end





