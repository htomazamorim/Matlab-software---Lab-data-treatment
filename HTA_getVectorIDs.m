function vectorID = HTA_getVectosIDs( fileData )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    i=2; % Denota a primeira posição útil de fileData
    j=1; % Percorre as colunas de vectorID

    % Preenche-se a primeira posição do vetor de ID's
    vectorID (1, j) = fileData(1, 2);
    vectorID (2, j) = i;
    
    % Avança-se para a coluna seguinte, ainda em branco
    j = j+1;
    
    % Vasculha-se todos os ID's
    % Guarda-se na primeira linha os valores dos ID's
    % Na segunda linha armazena-se o número da coluna da primeira ocorrencia do ID
    for i = 3 : length( fileData(1,:) )
        if( vectorID (1, j-1) ~= fileData(1, i) )
            vectorID (1, j) = fileData(1, i);
            vectorID (2, j) = i;
            j = j+1;
        end
    end
end

