function [ output_args ] = HTA_elipsoidBatch( directory, boulusOrInfusion )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

f = [1.0, 1.5, 2.5, 3.5, 5.5, 6.5, 8.5, 9.5, 11.5, 14.5, 15.5, 18.5, 20.5];

folders = dir(directory);
folders = struct2cell(folders);

F=[8.64, 5.78];
p=[3,4];                
tam = size(folders);

file = fopen('Batch_elipsoid_Boulus_SAMR_10M.txt', 'w');

fprintf(file, 'Elipsoid-Infusao\n\n');

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
            [constants, val] = fminsearch(func, initialModelConstants);

            R = constants(1);
            I = constants(2);
            G = constants(3);
            H = constants(4);

            fprintf(file, ['     R: ', num2str(R), '\n']);
            fprintf(file, ['     I: ', num2str(I), '\n']);
            fprintf(file, ['     G: ', num2str(G), '\n']);
            fprintf(file, ['     H: ', num2str(H), '\n']);

            Hes = HTA_elip( R, I, G, H );
            M = [Hes(1,1), Hes(1,3), Hes(1,4); Hes(3,1), Hes(3,3), Hes(3,4); Hes(4,1), Hes(4,3), Hes(4,4)];
                
            [Vh, Dh] = eig(Hes);
            [Vm, Dm] = eig(M);
             
            errPhiM = 2*p(1)*((val^2)*13/(26-p(1)))/(F(1));
            errPhiH = 2*p(2)*((val^2)*13/(26-p(2)))/(F(2));
                   
            detM = Dm(1,1)*Dm(2,2)*Dm(3,3);
            detH = Dh(1,1)*Dh(2,2)*Dh(3,3)*Dh(4,4);
                
            vol = [4*pi*sqrt(errPhiM^3)/(3*sqrt(detM)), 4*pi*sqrt(errPhiH^3)/(3*sqrt(detH))];
            titles = {'     V (p=3) =  ', '     V (p=4) =  '};
            
            for n=1:2
                fprintf(file, titles{n});
                
                fprintf(file, num2str(vol(n)));
                
                fprintf(file, '\n');
            end
            
            fprintf(file, ['     L1: ', num2str(sqrt(errPhiH/Dh(1,1))), '\n']);
            fprintf(file, ['     L2: ', num2str(sqrt(errPhiH/Dh(2,2))), '\n']);
            fprintf(file, ['     L3: ', num2str(sqrt(errPhiH/Dh(3,3))), '\n']);
            fprintf(file, ['     L4: ', num2str(sqrt(errPhiH/Dh(4,4))), '\n']);
            
            % Calculando Erro MAXIMO para o elip 3D
            theta = linspace(0, 2*pi);
            phi = linspace(-pi/2, pi/2);
            [theta, phi] = meshgrid(theta, phi);
            rho = 1;
            [x,y,z] = sph2cart(theta, phi, rho);
            
            x = x / sqrt((Dm(1,1)/errPhiM));
            y = y / sqrt((Dm(2,2)/errPhiM));
            z = z / sqrt((Dm(3,3)/errPhiM));
            
            xn = (Vm(1,1)*x + Vm(1,2)*y+ Vm(1,3)*z)./(sqrt(Vm(1,1)^2+Vm(1,2)^2)+Vm(1,3)^2);
            yn = Vm(2,1)*x + Vm(2,2)*y+ Vm(2,3)*z./(sqrt(Vm(2,1)^2+Vm(2,2)^2)+Vm(2,3)^2);
            zn = Vm(3,1)*x + Vm(3,2)*y+ Vm(3,3)*z./(sqrt(Vm(3,1)^2+Vm(3,2)^2)+Vm(3,3)^2);
            
            pointsMtx = size(xn);
            
            errMaxR = xn(1,1);
            errMaxG = yn(1,1);
            errMaxH = zn(1,1);
            
            for a = 1 : pointsMtx(1)
                for b = 1: pointsMtx(2)
                    if( xn(a,b) > errMaxR )
                        errMaxR = xn(a,b);
                    end
                    
                    if( yn(a,b) > errMaxG )
                        errMaxG = yn(a,b);
                    end
                    
                    if( zn(a,b) > errMaxH )
                        errMaxH = zn(a,b);
                    end
                end
            end
            
            fprintf(file, '\n     Considerando p=3: \n');
            errors = [errMaxR, errMaxG, errMaxH];
            titles = {'     ErrMaxR =  ', '     ErrMaxG =  ', '     ErrMaxH =  '};
            for d=1:3
                fprintf(file, titles{d});
                
                fprintf(file, num2str(errors(d)));
                
                fprintf(file, '\n');
            end

            [x,y,z] = sph2cart(theta, phi, rho);
            
            x = x / sqrt((Dh(1,1)/errPhiH));
            y = y / sqrt((Dh(3,3)/errPhiH));
            z = z / sqrt((Dh(4,4)/errPhiH));
            
            xn = Vh(1,1)*x + Vh(1,3)*y+ Vh(1,4)*z;
            yn = Vh(3,1)*x + Vh(3,3)*y+ Vh(3,4)*z;
            zn = Vh(4,1)*x + Vh(4,3)*y+ Vh(3,4)*z;
            
            pointsMtx = size(xn);
            
            errMaxR = xn(1,1);
            errMaxG = yn(1,1);
            errMaxH = zn(1,1);
            
            for a = 1 : pointsMtx(1)
                for b = 1: pointsMtx(2)
                    if( xn(a,b) > errMaxR )
                        errMaxR = xn(a,b);
                    end
                    
                    if( yn(a,b) > errMaxG )
                        errMaxG = yn(a,b);
                    end
                    
                    if( zn(a,b) > errMaxH )
                        errMaxH = zn(a,b);
                    end
                end
            end
            
            fprintf(file, '\n     Considerando p=4: \n');
            errors = [errMaxR, errMaxG, errMaxH];
            titles = {'     ErrMaxR =  ', '     ErrMaxG =  ', '     ErrMaxH =  '};
            for d=1:3
                fprintf(file, titles{d});
                
                fprintf(file, num2str(errors(d)));
                
                fprintf(file, '\n');
            end
%             fprintf(file, '\n');
% 
%             for i = 1:13
%                 realPart = quickPrimeTable(2:end, id{j,3} + 6*medida);
%                 realPart = realPart';
%                 realPart(i) = 0;
%                 realPart = realPart(find(realPart));
% 
%                 imaginaryPart = quickPrimeTable(2:end, id{j,3} + 6*medida + 1);
%                 imaginaryPart = imaginaryPart';
%                 imaginaryPart(i) = 0;
%                 imaginaryPart = imaginaryPart(find(imaginaryPart));
% 
%                 f0 = f;
%                 f0(i) = 0;
%                 f0 = f0(find(f0));
% 
%                 % Definicao da funcao
%                 func = @(constants)HTA_minSquareSum(constants,f0,realPart,imaginaryPart);
% 
%                 % Minimizando os valores das constantes do modelo
%                 constants = fminsearch(func, initialModelConstants);
% 
%                 R = constants(1);
%                 I = constants(2);
%                 G = constants(3);
%                 H = constants(4);
% 
%                 fprintf(file, ['(', num2str(i+1), ')','Constants without frequencie:', num2str(f(i)),'\n']);
%                 fprintf(file, ['     R: ', num2str(R), '\n']);
%                 fprintf(file, ['     I: ', num2str(I), '\n']);
%                 fprintf(file, ['     G: ', num2str(G), '\n']);
%                 fprintf(file, ['     H: ', num2str(H), '\n']);
% 
%                 coef = HTA_calcSensitivityCoef(R, I, G, H);
% 
%                 for n=1:4
%                     titles = {'     coefR: ', '     coefI: ', '     coefG: ', '     coefH: '};
% 
%                     fprintf(file, titles{n});
% 
%                     for r=1:13
%                         fprintf(file, [num2str(coef{1, n}(r)), ';']);
%                     end
% 
%                     fprintf(file, '\n');
%                 end
% 
%                 fprintf(file, '\n');
%             end
% 
%         end
%         fprintf(file, '\n');

    end
    end   
end
fclose(file);

