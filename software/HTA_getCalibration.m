function [calibTable] = HTA_getCalibration( eventsLog )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

i=1;
j=3;
%str = eventsLog {1, j};
tam = size(eventsLog);
calibTable{1,1}=0;

while ( j <= tam(2) )
    str = eventsLog {1, j};
    
    if ( ~isempty ( strfind (str, 'Channel calibration') ) )
        % Insere-se a Legenda 1 - Channel Calibration
        calibTable{i, 1} = 1;
        
        % Preenche com EventID na coluna 2
        calibTable{i, 2} = eventsLog {2, j};
        
        % Procura-se a string 'PM' de fim de horário
        Index = strfind (str, 'PM');
        
        % Se não encontrar 'PM', procura-se 'AM'
        if ( isempty( Index ) )
            Index = strfind (str, 'AM');
        end        
        
        % Toma-se a string descritiva a partir do fim do horario (após 'AM' ou 'PM')
        calibTable{i, 3} = str(Index(1)+2:end);
        
        % Lê-se as LINHAS do Evento selecionado
        for k=3:tam(1)
            auxStr = eventsLog {k, j};
            
            % Toma-se a primeira palavra da linha lida
            firstWord = sscanf (auxStr, '%s', 1);
            
            if( strcmp (firstWord, 'Channel') )
                % Pega-se o indice de todos os '= ' na string
                % Index(1) => Equivale ao '=' após 'Channel'
                % Index(2) => Equivale ao '=' após 'RangeMax'
                % Index(3) => Equivale ao '=' após 'RangeMin'
                Index = strfind (eventsLog {k, j}, '=');
                
                calibTable{i, 4} = 'Channel:';
                calibTable{i, 5} = num2str( sscanf(auxStr(Index(1)+1:end), '%d', 1));
                calibTable{i, 6} = 'Range Max:';
                calibTable{i, 7} = sscanf( auxStr(Index(2)+1:end), '%s', 1);
                calibTable{i, 8} = 'Range Min:';
                calibTable{i, 9} = sscanf( auxStr(Index(3)+1:end), '%s', 1);
                break;
            end
        end
        
    elseif ( ~isempty ( strfind (str, 'Tube calibration') ) )
        % Preenche com EventID na coluna 2
        calibTable{i, 2} = eventsLog {2, j};
        
        % Procura-se a string 'PM' de fim de horário
        Index = strfind (str, 'PM');
        
        % Se não encontrar 'PM', procura-se 'AM'
        if ( isempty( Index ) )
            Index = strfind (str, 'AM');
        end
        
        % Toma-se a string descritiva a partir do fim do horario (após 'AM' ou 'PM')
        calibTable{i, 3} = str(Index(1)+2:end);
        
        if ( ~isempty ( strfind (str, 'Closed') ) )
            % Insere-se a Legenda 2 - Tube calibration: Closed
            calibTable{i, 1} = 2;
            
            % Lê-se as LINHAS do Evento selecionado
            for k=3:tam(1)
                auxStr = eventsLog {k, j};
                
                % Verifica se 'Es' existe na presente string
                firstWord = strfind (auxStr, 'Es');
                
                % Entra no if quando encontrar 'Es'
                if( ~isempty ( firstWord ) )
                    % Preenchendo com a constante Es
                    Index = strfind (auxStr, ':');

                    if( ~isempty(Index) )
                        calibTable{i, 4} = 'Es:';
                        % Lê-se a partir do ':' para tomar o número
                        calibTable{i, 5} = sscanf(auxStr(Index(1)+1:end), '%s', 1);
                    else
                        % Não há o dado 'Es'
                        calibTable{i, 4} = [];
                        calibTable{i, 5} = [];
                    end

                    % Preenchendo com a constante Rs
                    % Pois 'Rs' vem na linha de baixo
                    auxStr = eventsLog {k+1, j};
                    Index = strfind (auxStr, ':');

                    if( ~isempty(Index) )
                        calibTable{i, 6} = 'Rs:';
                        calibTable{i, 7} = sscanf(auxStr(Index(1)+1:end), '%s', 1);
                    else
                        calibTable{i, 6} = [];
                        calibTable{i, 7} = [];
                    end

                    % Preenchendo com a constante COD
                    auxStr = eventsLog {k+2, j};
                    Index = strfind (auxStr, ':');

                    if( ~isempty(Index) )
                        calibTable{i, 8} = 'COD:';
                        calibTable{i, 9} = sscanf(auxStr(Index(1)+1:end), '%s', 1);
                    else
                        calibTable{i, 8} = [];
                        calibTable{i, 9} = [];
                    end

                    break;
                end
            end
         
        else
            % Insere-se a Legenda 3 - Tube calibration: Opened
            calibTable{i, 1} = 3;
            
            % Lê-se as LINHAS do Evento selecionado
            for k=3:tam(1)
                auxStr = eventsLog {k, j};
                
                % Variavel auxiliar para encontrar Rt
                firstWord = sscanf (auxStr, '%s', 1);
                
                if( or ( strcmp (firstWord, 'Rt'), strcmp (firstWord, 'Rt:')) )
                    % Preenchendo com a constante Rt
                    Index = strfind (auxStr, ':');

                    if( ~isempty(Index) )
                        calibTable{i, 4} = 'Rt:';
                        calibTable{i, 5} = sscanf(auxStr(Index(1)+1:end), '%s', 1);
                    else
                        calibTable{i, 4} = [];
                        calibTable{i, 5} = [];
                    end
                    
                    break;
                end
            end 
        end
        
    else
        % Toma-se essas acoes se o evento atual nao for calibracao 
        j = j+1;
        continue;
    end
    
    % Pula linha
    i = i+1;
    
    % Avança uma coluna na leitura
    j = j+1;
end


end

