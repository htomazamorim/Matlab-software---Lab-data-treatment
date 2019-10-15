function [ out ] = HTA_averageBatch( directory )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

realPart = [0;0;0;0;0;0;0;0;0;0;0;0;0];
imaginaryPart = [0;0;0;0;0;0;0;0;0;0;0;0;0];
devPart = [0;0;0;0;0;0;0;0;0;0;0;0;0];
devImag = [0;0;0;0;0;0;0;0;0;0;0;0;0];

f = [1.0, 1.5, 2.5, 3.5, 5.5, 6.5, 8.5, 9.5, 11.5, 14.5, 15.5, 18.5, 20.5];

folders = dir(directory);
folders = struct2cell(folders);

tam = size(folders);

vet=[5];

for k=3:7
    fAdress = fullfile(directory, folders{1,k});
       
    % Lendo todos os arquivos da pasta
    allFiles = dir(fAdress);
    allFiles = struct2cell(allFiles);
    
    allFilesSize = size(allFiles);
    
    containsLog = 0;
    
    for m = 3:allFilesSize(2)
        str = allFiles{1, m};

        if( and (strfind (str, 'log.txt'), containsLog == 0) )
        	% k = coluna de allFiles que possui o arquivo log
            j = m;
            containsLog = 1;
        end
    end
    
    data = HTA_readExperiment(fAdress, allFiles{1, j});
    quickPrimeTable = cell2mat(data{1,1});
    eventsIDs = HTA_getVectorIDs( quickPrimeTable );

    % ---- Encontrando os ID's corretos
    markers = HTA_findMarkers(data{4,1});
    tam = size(markers);

    id = {};

    for i = 1:tam(1)
        if( ~isempty(strfind(markers{i, 2}, 'PBS')) )
            id{1,2} = i;
            id{1,1} = markers{i,1};
        end
        
        if( ~isempty(strfind(markers{i, 2}, 'MCh  30  ug/kg')) )
            id{2,2} = i;
            id{2,1} = markers{i,1};
        end
        
        if( ~isempty(strfind(markers{i, 2}, 'MCh  100  ug/kg')) )
            id{3,2} = i;
            id{3,1} = markers{i,1};
        end
        
        if( ~isempty(strfind(markers{i, 2}, 'MCh  300  ug/kg')) )
            id{4,2} = i;
            id{4,1} = markers{i,1};
        end
        
        if( ~isempty(strfind(markers{i, 2}, 'MCh  1000  ug/kg')) )
            id{5,2} = i;
            id{5,1} = markers{i,1};
        end
    end

    tam = size(eventsIDs);

    for i = 1:tam(2)
        if( abs(eventsIDs(1, i)) == id{1,1}+1 )
            id{1,3} = eventsIDs(2, i);
        end

        if( abs(eventsIDs(1, i)) == id{2,1}+1 )
            id{2,3} = eventsIDs(2, i);
        end
        
        if( abs(eventsIDs(1, i)) == id{3,1}+1 )
            id{3,3} = eventsIDs(2, i);
        end
        
        if( abs(eventsIDs(1, i)) == id{4,1}+1 )
            id{4,3} = eventsIDs(2, i);
        end
        
        if( abs(eventsIDs(1, i)) == id{5,1}+1 )
            id{5,3} = eventsIDs(2, i);
        end
    end

    % ------------------------


    for j=vet
        %Toma a dose de 100

        
        for medida=13:15
            % Somador das medidas do 2/30 encontradas
            realPart = realPart+quickPrimeTable(2:end, id{j,3} + 6*medida);
            imaginaryPart = imaginaryPart+quickPrimeTable(2:end, id{j,3} + 6*medida + 1);
        end
    end
end

realPart = realPart./5;
imaginaryPart = imaginaryPart./5;
            
for k=3:7
    fAdress = fullfile(directory, folders{1,k});
       
    % Lendo todos os arquivos da pasta
    allFiles = dir(fAdress);
    allFiles = struct2cell(allFiles);
    
    allFilesSize = size(allFiles);
    
    containsLog = 0;
    
    for m = 3:allFilesSize(2)
        str = allFiles{1, m};

        if( and (strfind (str, 'log.txt'), containsLog == 0) )
        	% k = coluna de allFiles que possui o arquivo log
            j = m;
            containsLog = 1;
        end
    end
    
    data = HTA_readExperiment(fAdress, allFiles{1, j});
    quickPrimeTable = cell2mat(data{1,1});
    eventsIDs = HTA_getVectorIDs( quickPrimeTable );

    % ---- Encontrando os ID's corretos
    markers = HTA_findMarkers(data{4,1});
    tam = size(markers);

    id = {};

    for i = 1:tam(1)
        if( ~isempty(strfind(markers{i, 2}, 'PBS')) )
            id{1,2} = i;
            id{1,1} = markers{i,1};
        end
        
        if( ~isempty(strfind(markers{i, 2}, 'MCh  30  ug/kg')) )
            id{2,2} = i;
            id{2,1} = markers{i,1};
        end
        
        if( ~isempty(strfind(markers{i, 2}, 'MCh  100  ug/kg')) )
            id{3,2} = i;
            id{3,1} = markers{i,1};
        end
        
        if( ~isempty(strfind(markers{i, 2}, 'MCh  300  ug/kg')) )
            id{4,2} = i;
            id{4,1} = markers{i,1};
        end
        
        if( ~isempty(strfind(markers{i, 2}, 'MCh  1000  ug/kg')) )
            id{5,2} = i;
            id{5,1} = markers{i,1};
        end
    end

    tam = size(eventsIDs);

    for i = 1:tam(2)
        if( abs(eventsIDs(1, i)) == id{1,1}+1 )
            id{1,3} = eventsIDs(2, i);
        end

        if( abs(eventsIDs(1, i)) == id{2,1}+1 )
            id{2,3} = eventsIDs(2, i);
        end
        
        if( abs(eventsIDs(1, i)) == id{3,1}+1 )
            id{3,3} = eventsIDs(2, i);
        end
        
        if( abs(eventsIDs(1, i)) == id{4,1}+1 )
            id{4,3} = eventsIDs(2, i);
        end
        
        if( abs(eventsIDs(1, i)) == id{5,1}+1 )
            id{5,3} = eventsIDs(2, i);
        end
    end

    % ------------------------


    for j=vet
        %Toma a dose de PBS

        
        for medida=1:1
            devReal = (realPart-quickPrimeTable(2:end, id{j,3} + 6*medida)).^2;
            devImag = (imaginaryPart-quickPrimeTable(2:end, id{j,3} + 6*medida + 1)).^2;
        end
    end
end
            
devReal = sqrt(devReal./4); 
devImag = sqrt(devImag./4);
            
realPart = realPart';    
imaginaryPart = imaginaryPart';
devReal=devReal';
devImag=devImag';    
            
            
            
% initialModelConstants = [R_inicial, I_inicial, G_inicial, H_inicial]
initialModelConstants = [0.2, 0.01, 5, 22];

% Definicao da funcao
func = @(constants)HTA_minSquareSum(constants,f,realPart,imaginaryPart);

% Minimizando os valores das constantes do modelo
constants = fminsearch(func, initialModelConstants);

R = constants(1);
I = constants(2);
G = constants(3);
H = constants(4);  
            
            
            
            
    out{1} = realPart;
    out{2} = imaginaryPart;
    out{3} = devReal;
    out{4} = devImag;
    out{5} = [R, I, G, H];

end

