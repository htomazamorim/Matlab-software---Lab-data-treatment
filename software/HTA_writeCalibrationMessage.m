function [ msg ] = HTA_writeCalibrationMessage( cP, cS, date)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

msg{1,1} = ['Data: ', date{1}];
msg{1,2} = ['Duração: ', date{2}, ' às ', date{3}];
msg{1,3} = ' ';
msg{1,4} = 'Calibração do Experimento';
msg{1,5} = ' ';

j=5;

tam = length(cS);

for i=1:tam
    j=j+1;
    msg{1,j} = ['\bf\color{black}', cP{i,3}, '\rm\rm'];
    
    if (cP{i,1} == 1)    
        % Escreve Channel
        j=j+1;
        msg{1,j} = [ cP{i,4}, cP{i,5}];
        
        % Escreve Range Max
        j=j+1;
        
        if( ~isempty(cP{i,7}) )
            msg{1,j} = ['\color{black}', cP{i,6}, ' ', cP{i,7}, ' cmH2O\rm    ', cS{i,1}];
        else
            msg{1,j} = cS{i,1};
        end
        
        % Escreve Range Min
        j=j+1;
        
        if( ~isempty(cP{i,9}) )
            msg{1,j} = ['\color{black}', cP{i,8}, ' ', cP{i,9}, ' cmH2O\rm    ', cS{i,2}];
        else
            msg{1,j} = cS{i,2};
        end
        
        if(i<tam)
            j=j+1;
            msg{1,j} = ' ';
        end
        
    elseif(cP{i,1} == 2)
        % Escreve Rs ou Rt
        j=j+1;
        
        if( ~isempty(cP{i,7}) )
            msg{1,j} = ['\color{black}', cP{i,6}, ' ', cP{i,7}, ' cmH2O.s/mL\rm    ', cS{i,2}];
        else
            msg{1,j} = cS{i,2};
        end
        
        if(i<tam)
            j=j+1;
            msg{1,j} = ' ';
        end
        
    else
        % Escreve Rs ou Rt
        j=j+1;
        
        if( ~isempty(cP{i,5}) )
            msg{1,j} = ['\color{black}', cP{i,4}, ' ', cP{i,5}, ' cmH2O.s/mL\rm    ', cS{i,1}];
        else
            msg{1,j} = cS{i,1};
        end
        
        if(i<tam)
            j=j+1;
            msg{1,j} = ' ';
        end
    end
end


end

%msg = {cP{1,3}, ' ', ['Range Max: ', cP{1,2}, '      ', cP{1,2}],['Range Max: ', cP{1,2}, '      ', cP{1,2}]};


