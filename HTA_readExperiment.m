function resFinal = HTA_readExperiment(filePath, fileName)
    % Definição da célula de dados
    % data = {Impedances, log ,Parameters}
    
    % Variável que verifica o sucesso de leitura
    OK = 1;
    
    data = HTA_getFilesNames(filePath, fileName);
    
    %------- Lendo o QuickPrime
    
    ID = fopen( data{1, 1} );    
    
    casoErro = {'2', '2 v5.2', '6','6 v5.2'};
    
    i=1;
    
    while ( and( ID == -1, i <= 4) )
    	aux = strrep(data{1, 1}, '3 v5.2', casoErro{1, i});
        ID = fopen( aux );
        i = i + 1;
    end
    
    if (ID ~= -1)
        %Lista das frequências do experimento
        frequencies = {'1', '1.5', '2.5','3.5','5.5', '6.5', '8.5', '9.5', '11.5', '14.5', '15.5', '18.5', '20.5', 'end'};

        % currentReading é variável que captura os caracteres 
        currentReading = textscan(ID, '%s', 1);

        % Procura-se o caractere '->', pois a partir dele inciam-se os ID's dos
        % eventos
        while (strcmp(currentReading{1,1}, '->') == 0)
            currentReading = textscan(ID, '%s', 1);
        end

        % Lê-se todos os EventID's
        EventsIds = fscanf(ID, '%d');
        % Verifica-se a quantidade de colunas da tabela
        sizeOfEventsIds = size(EventsIds);

        % Tabela principal que contem os dados. Iniciamos sua célula principal
        % com 0
        mainTable{1,1} = 0;

        % Preenche-se a primeira linha com os ID's
        for i = 1:(sizeOfEventsIds-1)
            mainTable{1,i+1} = EventsIds(i,1);
        end

        %Capturam-se caracteres até o inicio da leitura das frequências
        while ( isempty( strfind(currentReading{1,1}{1}, 'Hz') ) )
            currentReading = textscan(ID, '%s', 1);
        end
        
        % Encontra o início das frequencias
        while (strcmp(currentReading{1,1}, '1') == 0)
            currentReading = textscan(ID, '%s', 1);
        end
        
        % -- Verificacao extra
        
            % Caso a saída seguinte não seja um número, é sinal de que não se
            % encontrou a primeira frequencia, entao faz-se a verificacao
            % abaixo para garantir que chegou-se no ponto correto de leitura.
        %    currentReading = textscan(ID, '%s', 1);
         %   aux = str2num(currentReading{1}{1});

            i = 2;  % i percorre as linhas da tabela
            j = 1;  % j percorre as colunas da tabela
            k = 2;  % k capta o momento em atinge-se a proxima frequência

          %  while ( isempty(aux) )
           %     currentReading = textscan(ID, '%s', 1);
            %    aux = str2num(currentReading{1}{1});
             %   j=0;
            %end
        
        % -----
        
        % Preenche-se a primeira frequencia -> 1
        mainTable{2,1} = 1;
        
        readedQuickPrime = fscanf(ID, '%f');
        times = length(readedQuickPrime);
        
        %Le-se até o fim do arquivo
        for m = 1:times
            % Compara-se a leitura atual com as frequências para detectar se é
            % necessário pular de linha
            
            %if( currentReading{1} == str2double(frequencies{1,k}) )
            if( readedQuickPrime(m,1) == str2double(frequencies{1,k}) )
                i=i+1;   % Pula linha
                k=k+1;   % Toma-se a próxima frequência para comparação
                j=0;     % Reinicializa-se a variável para percorrer as colunas
            end

            % Caminha-se sobre as colunas incrementando-se j
            j=j+1;
            % Preenche-se a tabela de dados com a leitura atual
            mainTable{i,j} =  readedQuickPrime(m,1);
            %mainTable{i,j} = currentReading{1, 1};
            
            %Faz-se a proxima leitura
%            currentReading = textscan(ID, '%s', 1);
            
%              while ( isempty( currentReading ) )
%                  currentReading = textscan(ID, '%s', 1);
%              end
%             
%             currentReading{1,1} = strtrim(currentReading{1,1});
        end
        
        fclose(ID);
    else
        OK = 2;
        mainTable{1,1} = 0;
    end
    
    % ------- Lendo o Arquivo Log 
    
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

            % Strtrim retira os espaços em branco da String para o loop poder
            % encerrar, pois, para o Matlab 'Events' é diferente de 'Events '
            %auxStr = strtrim (readLine);
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

            % Strtrim retira os espaços em branco da String para o loop poder
            % encerrar, pois, para o Matlab 'Events' é diferente de 'Events '
            %auxStr = strtrim (readLine);
        end

        % Toma-se o breakline como sendo a data do experimento
        currentReading = textscan(ID, '%s', 1);
        breakLine = currentReading{1,1};

        % Lendo os eventos
        readLine = fgetl(ID);
        i=0; j=2;

        while ( ~feof(ID) )
            while( length (strfind ( sscanf (readLine, '%s', 1), '/' )) ~= 2 )
                i = i + 1;
                log { i, j } = readLine;
                readLine = fgetl(ID);

                if (readLine == -1)
                    break;
                end
            end

            if (readLine ~= -1)
                % Registra próximo evento
                i = 1;
                j = j+1;

                % Armazena a linha com a data na primeira linha do evento
                log {1 , j} = readLine;

                % Toma a proxima leitura
                readLine = fgetl(ID);
            end
        end

        % Adiciona-se a data perdida na primeira leitura de breakline
        log {1 , 2} = strcat( breakLine{1,1}, {' '}, log {1 , 2} );

        tam = size(log);

        for i=1:tam(1)
           for j=1:tam(2)
            if( isempty ( log{i,j} ) )
                log{i,j} = ' ';
            end
           end
        end

        fclose(ID);
    else
        OK = 3;
    end
    
    %--- Lendo Parameters
    
    % Redefinindo o arquivo atual para o Log.txt
    ID = fopen( data{1, 3} );
    
    if(ID ~= -1)
        i = 0;

        % Realiza-se leitura linha a linha até o fim do arquivo
        while (~feof(ID))
            i = i + 1;
            readLine = fgetl(ID);
            parameters { i, 1 } = readLine;        
        end

        fclose(ID);
    else
        OK = 4;
    end

    % ----------------------------------------
    
    % Verificação da tabela
    tam = size(mainTable);
    
    for i = 1:tam(1)
        for j = 1:tam(2)
            if( isempty(mainTable{i,j}) )
               %OK = 0;
               %break;
            end
        end
    end
    
    % ----------------------
    
    % Definição da saida
    if(OK)
        resFinal{1,1} = mainTable;
        resFinal{2,1} = hardwareLog;
        resFinal{3,1} = log;
        resFinal{4,1} = parameters;
        resFinal{5,1} = 'ok';
    elseif(OK == 2)
        resFinal{5,1} = 'Problema QuickPrime';
    elseif(OK == 3)
        resFinal{5,1} = 'Problema Log';
    elseif(OK == 4)
        resFinal{5,1} = 'Problema Parameters';
    elseif(OK == 0)
        resFinal{5,1} = 'Calulas vazias na leitura de QuickPrime';
    end    
    
end