function [ coef ] = HTA_calcSensitivityCoef( R, I, G, H )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

f = [1.0, 1.5, 2.5, 3.5, 5.5, 6.5, 8.5, 9.5, 11.5, 14.5, 15.5, 18.5, 20.5];
w = 2*pi*f;
alpha = 2*atan(H/G)/pi;

imPart = I*w - (H./(w.^alpha));
rePart = R + (G./(w.^alpha));

module = ( (imPart).^2 + (rePart).^2 ).^(0.5);

coefR = abs(R)*((rePart./module)./module);
coefI = abs(I)*(((imPart.*w)./module)./module);
coefG = abs(G)*((rePart.*((G^2 + H^2 + ((2*H*G/pi)*log(w)))./((G^2 + H^2)*(w.^alpha))))./module)./module;
coefH = (-1)*abs(H)*((imPart.*((G^2 + H^2 - ((2*H*G/pi)*log(w)))./((G^2 + H^2)*(w.^alpha))))./module)./module;

coef = {coefR, coefI, coefG, coefH};

end

