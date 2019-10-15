function output = HTA_getData(fileData, IDs, eventID, request)
%GETDATA Summary of this function goes here
%   Detailed explanation goes here
    i=1;
    
    %IDs = getVectorIDs(fileData);
    % Procurar pelo evento de ID = eventID
    % Os id's constam na primeira linha da tabela lida
    while( not( IDs(1, i) == eventID ) )
        i=i+1;
    end
    
    %Toma-se a coluna em fileData no qual tem-se aquele ID pela primeira vez
    i = IDs(2, i);
    
    % Verifica o ensaios de calibração
    if( or(eventID == fileData(1, 2), eventID == fileData(1, 4)) )
        % Retorna erro se a requisição for diferente de 'Re(z)' ou 'Im(z)' para
        % o ensaio de calibração
        if( not ( strcmp(request, 'Re(z)') | strcmp(request, 'Im(z)') ) )
            output = 'Error: informação requisitada não presente no evento';
        
        % Resgata a parte real dos ensaios de calibração
        elseif ( strcmp(request, 'Re(z)') )
            output = fileData(2:end, i);
        
        % Resgata a parte imaginária dos ensaios de calibração
        else ( strcmp(request, 'Im(z)') )
            output = fileData(2:end, i+1);
        end       
    else
        % Retorna a parte real
        if( strcmp(request, 'Re(z)') )
            output = fileData(2:end, i);
        % Retorna a parte imaginaria
        elseif( strcmp(request, 'Im(z)') )
            output = fileData(2:end, i+1);
        % Retorna 'E(z)'
        elseif( strcmp(request, 'E(z)') )
            output = fileData(2:end, i+2);
        % Retorna 'Mag(z)'
        elseif( strcmp(request, 'Mag(z)') )
            output = fileData(2:end, i+3);
        % Retorna 'Coh(z)'
        elseif( strcmp(request, 'Coh(z)') )
            output = fileData(2:end, i+4);
        % Retorna 'Ph(z)'
        elseif( strcmp(request, 'Ph(z)') )
            output = fileData(2:end, i+5);
        % Retorna erro no caso de requisição inválida
        else
            output = 'Error: informação requisitada não presente no evento';
        end
    end  
end
