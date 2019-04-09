function [ data ] = HTA_getFilesNames( filePath, fileName )
%   Detailed explanation goes here

    % Declaração do arquivo
    arquivo = fullfile(filePath, fileName);
    
    % Declara os tipos de arquivo
    tipoArquivo = {'-Impedances-Quick Prime-3 v5.2','-log','-Parameters', '_log', '-Raw data-Quick Prime-3 v5.2','-Raw data-SnapShot-150 v5.2','-Raw data-TLC', '-Impedances-Quick Prime-2', '-Raw data-Quick Prime-2','-Raw data-Quick Prime-3','-Raw data-SnapShot-150'};    
    
    %Cria os filesIDs.
    k = 20;
    auxErroLog = -1;
    auxIndices = [1,2,3];
    
    for i=1:11
        if( ~isempty( strfind(fileName, tipoArquivo{1,i}) ) )
            k = i;
            auxErroLog = i;
            break;
        end
    end
    
    if(k <= 3)
        auxIndices(k)=0;
        auxIndices = auxIndices(find(auxIndices));

        data{1, k} = arquivo;

        arquivo = strrep(arquivo, tipoArquivo{1, k}, tipoArquivo{ 1, auxIndices(1) });
        data{ 1, auxIndices(1) } = arquivo;

        arquivo = strrep(arquivo, tipoArquivo{ 1, auxIndices(1) }, tipoArquivo{ 1, auxIndices(2) });
        data{ 1, auxIndices(2) } = arquivo;
    elseif ( k == 4 )
        data{1, 2} = arquivo;
        
        arquivo = strrep(arquivo, tipoArquivo{1, 4}, tipoArquivo{1, 1});
        data{1, 1} = arquivo;
            
        arquivo = strrep(arquivo, tipoArquivo{1, 1}, tipoArquivo{1, 3});
        data{1, 3} = arquivo;        
    else
        arquivo = strrep(arquivo, tipoArquivo{1, k}, tipoArquivo{1, 1});
        data{1, 1} = arquivo;
        
        arquivo = strrep(arquivo, tipoArquivo{1, 1}, tipoArquivo{1, 2});
        data{1, 2} = arquivo;

        arquivo = strrep(arquivo, tipoArquivo{1, 2}, tipoArquivo{1, 3});
        data{1, 3} = arquivo;
    end
    
    % Este for se encarrega de abrir os arquivos apropriados se os aruivos
    % selecionados para abrir forem os incorretos
    
end

