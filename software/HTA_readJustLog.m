function [ resFinal ] = HTA_readJustLog( filePath, fileName )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

    data = HTA_getFilesNames(filePath, fileName);
   
    % Variável que verifica o sucesso de leitura
    OK = 1;
    
    % Redefinindo o arquivo atual para o Log.txt
    ID = fopen( data{1, 2} );
    
    if ( ID == -1 )
    	data{1, 2} = strrep(data{1, 2}, '-log', '_log');
        ID = fopen( data{1, 2} );
    end
    
    if(ID ~= -1)
        i = 0;
        readLine = fgetl(ID);
        auxStr = readLine;

        % Procura-se a palavra 'Subjects', pois a partir dela inciam-se os ID's dos
        % eventos
        while ( isempty( strfind(readLine, 'Subjects') ) )
            i = i + 1;
            hardwareLog { i, 1 } = readLine;
            readLine = fgetl(ID);

            if(readLine == -1)
                OK = 0;
                break;
            end
        end

        i = 1;
        readLine = fgetl(ID);
        %auxStr = readLine;

        % Preenche-se a celula vazia da primeira coluna em log{,}
        log {1 , 1} = 'Subjects';

        % Preenche-se a primeira coluna de log{,} com os dados de Subjects
        while ( isempty( strfind(readLine, 'Events') ) )
            i = i + 1;
            log { i, 1 } = readLine;
            readLine = fgetl(ID);

            if(readLine == -1)
                OK = 0;
                break;
            end
        end
        
        i = 0;
        j = 2;
        readLine = fgetl(ID);

        while( ~feof(ID) )	
            if( strcmp(readLine, ' ') )
                i = 0;
                j = j+1;
                readLine = fgetl(ID);
                continue;
            end
            
            i = i + 1;
            log{i, j} = readLine;
            readLine = fgetl(ID);
            
            if (readLine == -1)
                break;
            end
        end
        
        fclose(ID);
    else
        OK = 0;
    end
    
    % -------------------
    
    % Preenchendo vazios
    tam = size(log);

    for i=1:tam(1)
    	for j=1:tam(2)
        	if( isempty ( log{i,j} ) )
            	log{i,j} = ' ';
            end
        end
	end
    
    
    % Definição da saida
    if(OK)
        resFinal{1,1} = hardwareLog;
        resFinal{2,1} = log;
        resFinal{3,1} = 'ok';
    else
        resFinal{3,1} = 'not';
    end
end

