function [ markers ] = HTA_findMarkers( parameters )
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
        
        % Lê o ID daquele marker
        id = sscanf(str, '%d', 1);
        
        % Procura-se a palavra 'From' na string
        % Geralmente, em cada marker, existe um 'From script'
        % Queremos ler a string até imediatamente antes dessa palavra
        Index2 = strfind(parameters{i,1}, 'From');
        
        if ( isempty(Index2) )
            % Caso não exista o 'From script', toma-se até o fim da linha
            Index2 = length(str)+1;
        end
        
        % Lê-se o trecho da string desejado
        event = str(Index(1)+6:Index2(1)-1);
        
        % Incrementa-se j
        j = j+1;
        % Atribui-se o encontrado à saída
        markers{j, 1} = id;
        markers{j, 2} = strtrim(event);
    end
end

end

