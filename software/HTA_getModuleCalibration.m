function [ module ] = HTA_getModuleCalibration( hardwareLog )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

for i = 1 : length(hardwareLog)
    str = hardwareLog{i,1};
    
    if ( or (strcmp (sscanf(str, '%s', 1), 'Module'), strcmp (sscanf(str, '%s', 1), 'Module:')) )
        break;
    end    
end

Index = strfind(str, 'Module');

module = sscanf( str(Index(2)+6:end), '%d', 1);

end

