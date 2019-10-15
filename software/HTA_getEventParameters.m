function [ dados ] = HTA_getEventParameters( resFinal, ID )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

eventsIDs = HTA_getVectorIDs( cell2mat( resFinal{1,1} ) );

% Parametro de controle
% Se param = 0 -> Não há o ID procurado no QuickPrime
% Se param = 1 -> existe o ID e retornam-se os parametros R, I, G, H, eta, CODcp
param = 0;

id = abs(ID);

% Verifica-se se o ID procurado consta na tabela do QuickPrime
for i = 1: length(eventsIDs)
    if ( abs(eventsIDs(1,i)) == id )
        param = 1;
    end
end

if(param)
    p = 0;
    % Tamanho da tabela com o arquibo log.txt
    tam = size (resFinal{3,1});
    
    % Procura da linha que contem os parametros
    for j = 1:tam(1,1)
        str = sscanf (resFinal{3,1}{j, id+1}, '%s', 1);
        
        if( strcmp (str, 'Rn') == 1 )
            % Encontrada a linha com os parametros
            p = j;
            break;
        end
    end
    
    if(p ~= 0)
        % Toma-se a string com os parametros
        str = resFinal{3,1}{p, id+1};
        
        % Procuram-se os sinais de '=' na str
        Index = strfind (str, '=');

        % Preenchimento com os parametros R, I, G, H, eta
        for k = 1:5
            dados{1,k} = sscanf (str(Index(k)+1:end), '%f', 1);
        end

        % String que contem o CODcp
        str = resFinal{3,1}{p+1, id+1};

        % Procuram-se os sinais de '=' na str
        Index = strfind (str, '=');

        % Preenche com o CODcp
        dados{1,6} = sscanf (str(Index(1)+1:end), '%f', 1);

    else
        % Se não forem encontrados os parametros preenchem-se com traços
        for k = 1:6
            dados{1,k} = '-';
        end
    end
    
else
    %Retorno caso de erro (não encontrar o ID)
    for k = 1:6
        dados{1,k} = 'erro';
    end
end

% Modelo de String
%'Rn = 0.20855 cmH2O.s/mL, I = -0.00012517 cmH2O.s.s/mL, G = 4.5552 cmH2O/mL, H = 27.785 cmH2O/mL, eta = 0.16394'

end

