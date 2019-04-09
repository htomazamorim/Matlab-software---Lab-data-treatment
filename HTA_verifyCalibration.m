function [ ansTable ] = HTA_verifyCalibration( module, calibrationTable )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

channelData = [61.4, -61.4];
tubeRsData = [2000, 1125, 600, 300, 150];
tubeRtData = [0.38, 0.1, 0.08, 0.02, 0.006];

tam = size(calibrationTable);
i=1;

for i=1:tam(1)
    if( calibrationTable{i,1} == 1)
        if( abs (str2num(calibrationTable{i,7}) - channelData(1)) <= 3 )
            ansTable{i,1} = '\bf\color[rgb]{0.13,0.7,0.3}Aceit�vel (Entre 58.4 cmH2O e 64.4 cmH2O)\rm\rm';
        elseif( (str2num(calibrationTable{i,7}) - channelData(1)) > 3 )
            ansTable{i,1} = '\bf\color{red}N�o Ideal (Superior a 64.4 cmH2O)\rm\rm';
        else
            ansTable{i,1} = '\bf\color{red}N�o Ideal (Inferior a 58.4 cmH2O)\rm\rm';
        end
        
        if( abs (str2num(calibrationTable{i,9}) - channelData(2)) <= 3 )
            ansTable{i,2} = '\bf\color[rgb]{0.13,0.7,0.3}Aceit�vel (Entre -64.4 cmH2O e -58.4 cmH2O)\rm\rm';
        elseif ( (str2num(calibrationTable{i,7}) - channelData(1)) > 3 )
            ansTable{i,2} = '\bf\color{red}N�o Ideal (Superior a -58.4 cmH2O)\rm\rm';
        else
            ansTable{i,2} = '\bf\color{red}N�o Ideal (Inferior a -64.4 cmH2O)\rm\rm';
        end
        
    elseif( calibrationTable{i,1} == 2)
        ansTable{i,1} = ' ';
        
        if ( ~isempty(calibrationTable{i,7}) )
            if( str2num(calibrationTable{i,7}) >= tubeRsData(module) )
                ansTable{i,2} = ['\bf\color[rgb]{0.13,0.7,0.3}Aceit�vel (Superior a ', num2str(tubeRsData(module)), ' cmH2O.s/mL)\rm\rm'];
            else
                ansTable{i,2} = ['\bf\color{red}N�o Ideal (Inferior a ', num2str(tubeRsData(module)), ' cmH2O.s/mL)\rm\rm'];
            end
        else
            ansTable{i,2} = ['\bf\color[rgb]{1, 0.78, 0.05}N�o Ideal: Par�metro Rs ausente\rm\rm'];
        end
        
    elseif( calibrationTable{i,1} == 3)
        ansTable{i,2} = ' ';
        
        if ( ~isempty(calibrationTable{i,5}) )
            if( str2num(calibrationTable{i,5}) <= tubeRtData(module) )
                ansTable{i,1} = ['\bf\color[rgb]{0.13,0.7,0.3}Aceit�vel (Inferior a ', num2str(tubeRtData(module)), ' cmH2O.s/mL)\rm\rm'];
            else
                ansTable{i,1} = ['\bf\color{red}N�o Ideal (Superior a ', num2str(tubeRtData(module)), ' cmH2O.s/mL)\rm\rm'];
            end
        else
            ansTable{i,1} = ['\bf\color[rgb]{1, 0.78, 0.05}N�o Ideal: Par�metro Rt ausente\rm\rm'];
        end
        
    end
end

end

