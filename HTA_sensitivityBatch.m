function [ output_args ] = HTA_sensitivityBatch(directory, boulusOrInfusion)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

f = [1.0, 1.5, 2.5, 3.5, 5.5, 6.5, 8.5, 9.5, 11.5, 14.5, 15.5, 18.5, 20.5];

folders = dir(directory);
folders = struct2cell(folders);

tam = size(folders);

file = fopen('Batch_parametersFile6.txt', 'w');

fprintf(file, 'Frequency analysis\n\n');
fprintf(file, 'Infusion rate\n\n');

for k=3:tam(2)
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
    
    boulus = {'PBS', 'MCh  30  ug/kg', 'MCh  100  ug/kg', 'MCh  300  ug/kg', 'MCh  1000  ug/kg'};
    infusion = {'PBS.', '48  ug/kg.min.', '96  ug/kg.min.', '192  ug/kg.min.'};
    id = {};

    for i = 1:tam(1)
        if(boulusOrInfusion)
            for j=1:5
                if( ~isempty(strfind(markers{i, 2}, boulus{j})) )
                    id{j,2} = i;
                    id{j,1} = markers{i,1};
                end
            end
        else
            for j=1:4
                if( strcmp(markers{i, 2}, infusion{j}) )
                    id{j,2} = i;
                    id{j,1} = markers{i,1};
                end
            end
        end
    end

    tam = size(eventsIDs);
    sizeId = size(id);

    for i = 1:tam(2)
        for j=1:sizeId(1)
            if( abs(eventsIDs(1, i)) == id{j,1}+1 )
                id{j,3} = eventsIDs(2, i);
            end
        end
    end

    % ------------------------

    fprintf(file, ['*** File name: ', folders{1, k}, '\n']);

    for j=1:(5*boulusOrInfusion+4*not(boulusOrInfusion))
        fprintf(file, ['Dose: ', markers{id{j,2}, 2}, '\n']);
        
        for medida=0:14
            fprintf(file, ['Medida nº: ', num2str(medida+1), '\n']);
            fprintf(file, '(1)Constants with all frequencies\n');

            % -------------

            realPart = quickPrimeTable(2:end, id{j,3} + 6*medida);
            realPart = realPart';

            imaginaryPart = quickPrimeTable(2:end, id{j,3} + 6*medida + 1);
            imaginaryPart = imaginaryPart';

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

            fprintf(file, ['     R: ', num2str(R), '\n']);
            fprintf(file, ['     I: ', num2str(I), '\n']);
            fprintf(file, ['     G: ', num2str(G), '\n']);
            fprintf(file, ['     H: ', num2str(H), '\n']);

            coef = HTA_calcSensitivityCoef(R, I, G, H);

            for n=1:4
                titles = {'     coefR: ', '     coefI: ', '     coefG: ', '     coefH: '};

                fprintf(file, titles{n});

                for r=1:13
                    fprintf(file, [num2str(coef{1, n}(r)), ';']);
                end

                fprintf(file, '\n');
            end

            fprintf(file, '\n');

            for i = 1:13
                realPart = quickPrimeTable(2:end, id{j,3} + 6*medida);
                realPart = realPart';
                realPart(i) = 0;
                realPart = realPart(find(realPart));

                imaginaryPart = quickPrimeTable(2:end, id{j,3} + 6*medida + 1);
                imaginaryPart = imaginaryPart';
                imaginaryPart(i) = 0;
                imaginaryPart = imaginaryPart(find(imaginaryPart));

                f0 = f;
                f0(i) = 0;
                f0 = f0(find(f0));

                % Definicao da funcao
                func = @(constants)HTA_minSquareSum(constants,f0,realPart,imaginaryPart);

                % Minimizando os valores das constantes do modelo
                constants = fminsearch(func, initialModelConstants);

                R = constants(1);
                I = constants(2);
                G = constants(3);
                H = constants(4);

                fprintf(file, ['(', num2str(i+1), ')','Constants without frequencie:', num2str(f(i)),'\n']);
                fprintf(file, ['     R: ', num2str(R), '\n']);
                fprintf(file, ['     I: ', num2str(I), '\n']);
                fprintf(file, ['     G: ', num2str(G), '\n']);
                fprintf(file, ['     H: ', num2str(H), '\n']);

                coef = HTA_calcSensitivityCoef(R, I, G, H);

                for n=1:4
                    titles = {'     coefR: ', '     coefI: ', '     coefG: ', '     coefH: '};

                    fprintf(file, titles{n});

                    for r=1:13
                        fprintf(file, [num2str(coef{1, n}(r)), ';']);
                    end

                    fprintf(file, '\n');
                end

                fprintf(file, '\n');
            end

        end
        fprintf(file, '\n');

    end
end

    fclose(file);


end

