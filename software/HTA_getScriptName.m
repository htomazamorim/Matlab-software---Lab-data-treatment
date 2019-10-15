function [ scriptName ] = HTA_getScriptName( parameters )

% tam = numero de linhas da tabela
tam = length(parameters);

% Auxiliar que preenche a saída
j=0;
for i=1:tam
    % Procura-se o 'marker' na linhai da tabela
    Index = strfind(parameters{i,1}, 'marker');
    
    % Se encontrou-se a palavra
    if ( ~isempty( Index ) )
        % str recebe a string da linha
        str = parameters{i,1};
                
        % Procura-se a palavra 'script' na string
        % Geralmente, em cada marker, existe um 'From script'
        % Queremos ler a string após essa palavra
        Index2 = strfind(parameters{i,1}, 'script');
        
        if ( isempty(Index2) )
            % Caso seja o 'From Script', com S maiusculo
            Index2 = strfind(parameters{i,1}, 'Script');
        end
           
        if ( ~isempty(Index2) )
            % Toma-se o nome do script
            scriptName = str(Index2(1)+6:end);
            break;
        else
            scriptName = 'none';
        end
        
    end
end

end