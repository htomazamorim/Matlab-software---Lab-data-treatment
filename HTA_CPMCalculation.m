function [ CPM ] = HTA_CPMCalculation( R, I, G, H, f )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

alpha = 2*atan(H/G)/pi;
dem = (2*pi).*f.^alpha;

real = R + (G./dem);
imaginary = (2*pi*I).*f - (H./dem);

CPM{1,1} = real;
CPM{1,2} = imaginary;


end

