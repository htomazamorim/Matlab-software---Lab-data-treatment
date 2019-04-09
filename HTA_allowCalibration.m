function [ k ] = HTA_allowCalibration( cS )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

k = 1;

tam = size (cS);

for i=1:tam(1)
   for j=1:tam(2)
       if( ~isempty ( strfind ( cS{i,j}, 'Ideal') ) )
           k = 0;
           break;
       end
   end
end

end