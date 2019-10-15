function [ res ] = HTA_batchCalibracao( directory )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

folders = dir(directory);

folders = struct2cell(folders);

tam = size(folders);

fileStatus = fopen('calibracao.txt', 'w');

fprintf(fileStatus, 'Calibração\n\n');

for i=3:tam(2)
    fAdress = fullfile(directory, folders{1,i});
       
    % Lendo todos os arquivos da pasta
    allFiles = dir(fAdress);
    allFiles = struct2cell(allFiles);
    
    allFilesSize = size(allFiles);
    
    containsLog = 0;
    containsParameters = 0;
    containsQuickPrime = 0;
    
    fprintf(fileStatus, [folders{1,i},'\n']);
    
    for j = 3:allFilesSize(2)
        str = allFiles{1, j};
        
        if( and (strfind (str, 'log.txt'), containsLog == 0) )
        	% k = coluna de allFiles que possui o arquivo log
            k = j;
            containsLog = 1;
        end
        
        if( and( strfind (str, 'Impedances-Quick Prime'), containsQuickPrime == 0) )
        	containsQuickPrime = 1;
        end
        
        if( and ( strfind (str, 'Parameters'), containsParameters == 0) )
        	containsParameters = 1;
        end
    end
    
    verifying = containsLog*containsParameters*containsQuickPrime;
    
    if( verifying == 1 )
        data = HTA_readJustLog(fAdress, allFiles{1,k});
        
        if( strcmp( data{3,1}, 'ok' ) )
            % Retorna o módulo de realização do experimento
            module = HTA_getModuleCalibration(data{1,1});

            % Parâmetros de calibração
            cP = HTA_getCalibration(data{2,1});

            % Verificação de Calibração
            cS = HTA_verifyCalibration(module, cP);

            textCalibration = HTA_allowCalibration(cS);

            if(textCalibration)
                fprintf(fileStatus, 'Status: Calibração perfeita\n\n');
%                res{i-2, 2} = 'Calibração perfeita';
            else
                fprintf(fileStatus, 'Status: Inapropriado\n\n');
                
                numberEvents = size(cP);
                
                for r=1:numberEvents(1)
                    if( cP{r,1} == 1 )
                        if( or ( ~isempty( strfind( cS{r,1}, 'Ideal') ), ~isempty( strfind( cS{r,2}, 'Ideal') ) ) )
                            fprintf(fileStatus, [cP{r,3}, '\n']);
                        else
                            continue;
                        end
                        
                        str = cS{r,1};
                        inicio = strfind( str, 'Não');
                        n = length(str);
                        
                        if( ~isempty( strfind( str, 'Ideal') ) )
                            fprintf(fileStatus, ['      RangeMax: ', str(inicio:n-6), '\n']);
                            fprintf(fileStatus, '\n');
                        end

                        str = cS{r,2};
                        inicio = strfind( str, 'Não');
                        n = length(str);
                        
                        if( ~isempty( strfind( cS{r,2}, 'Ideal') ) )
                            fprintf(fileStatus, ['      RangeMin: ', str(inicio:n-6), '\n']);
                            fprintf(fileStatus, '\n');
                        end
                        
                    elseif( cP{r,1} == 2 )
                        str = cS{r,2};
                        inicio = strfind( str, 'Não');
                        n = length(str);
                        
                        if( ~isempty( strfind( str, 'Ideal') ) )
                            fprintf(fileStatus, [cP{r,3}, '\n']);
                            fprintf(fileStatus, ['      Rs: ', str(inicio:n-6), '\n']);
                            fprintf(fileStatus, '\n');
                        end
                    else
                        str = cS{r,1};
                        inicio = strfind( str, 'Não');
                        n = length(str);
                        
                        if( ~isempty( strfind( str, 'Ideal') ) )
                            fprintf(fileStatus, [cP{r,3}, '\n']);
                            fprintf(fileStatus, ['      Rt: ', str(inicio:n-6), '\n']);
                            fprintf(fileStatus, '\n');
                        end
                    end

                end
                
            end
        else
            fprintf(fileStatus, 'Status: Erro de leitura\n\n');
        %    res{i-2, 2} = 'Erro de leitura';
        end
    else
        fprintf(fileStatus, 'Status: Sem arquivos\n\n');
%        res{i-2, 2} = 'Sem arquivos';
    end
end
fclose(fileStatus);
res= 1;
end

