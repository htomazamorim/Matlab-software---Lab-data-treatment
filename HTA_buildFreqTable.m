function [ data ] = HTA_buildFreqTable( realPart, imagPart, modelRealPart, modelImagPart )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

for i=1:length(realPart)
    data(1,i) = realPart(i);
    data(2,i) = modelRealPart(i);
    data(3,i) = abs( realPart(i) - modelRealPart(i) );
    data(4,i) = imagPart(i);
    data(5,i) = modelImagPart(i);
    data(6,i) = abs( imagPart(i) - modelImagPart(i) );
end

data = data';

end

