function [ experimentDate ] = HTA_getExperimentDate( hardwareLog )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

for i=1:length( hardwareLog )
    str = hardwareLog{i,1};
    str = sscanf(str, '%s', 1);
    str = strtrim(str);
    
    if ( or ( strcmp(str, 'Started') == 1, strcmp(str, 'Started:') == 1 ) )
        str = hardwareLog{i,1};
        Index = strfind(str, ':');
        
        data = sscanf( str(Index(1)+1:end) , '%s', 1);
        
        Index = strfind(str, data);
        horaInicio = sscanf( str(Index(1)+10:end) , '%s', 1);
        
        str = hardwareLog{i+1,1};
        Index = strfind(str, data );
        
        horaFim = sscanf( str(Index(1)+10:end) , '%s', 1);
        break;
    end
end

experimentDate = { data, horaInicio, horaFim };

end

