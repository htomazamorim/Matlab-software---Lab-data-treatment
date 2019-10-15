function [ desvio ] = HTA_desvioParametros ( A, B )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

if ( strcmp(B{1,1}, '-') == 1 )
    desvio{1,1} = '-';
    desvio{1,2} = '-';
    desvio{1,3} = '-';
    desvio{1,4} = '-';
else
    for i=1:4
        desvio{1, i} = abs( A(i) - B{1, i} );
    end
end

end

