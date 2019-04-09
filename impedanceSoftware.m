function varargout = impedanceSoftware(varargin)
% IMPEDANCESOFTWARE MATLAB code for impedanceSoftware.fig
%      IMPEDANCESOFTWARE, by itself, creates a new IMPEDANCESOFTWARE or raises the existing
%      singleton*.
%
%      H = IMPEDANCESOFTWARE returns the handle to a new IMPEDANCESOFTWARE or the handle to
%      the existing singleton*.
%
%      IMPEDANCESOFTWARE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMPEDANCESOFTWARE.M with the given input arguments.
%
%      IMPEDANCESOFTWARE('Property','Value',...) creates a new IMPEDANCESOFTWARE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before impedanceSoftware_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to impedanceSoftware_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @impedanceSoftware_OpeningFcn, ...
                   'gui_OutputFcn',  @impedanceSoftware_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before impedanceSoftware is made visible.
function impedanceSoftware_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to impedanceSoftware (see VARARGIN)

% Choose default command line output for impedanceSoftware
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes impedanceSoftware wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = impedanceSoftware_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in importFile.
function importFile_Callback(hObject, eventdata, handles)

% --- Reset do software
HTA_resetFrequencies(handles);
HTA_coloringBackgrounds(handles, 'white');
set(handles.escolhaEventID, 'visible', 'off');

% --- Inicio da leitura
[fileName, filePath] = uigetfile('*.txt', 'Seleciona o arquivo');
data = HTA_readExperiment(filePath, fileName);
quickPrimeTable = cell2mat(data{1,1});
IDs = HTA_getVectorIDs(quickPrimeTable);

frequencies = [1.0, 1.5, 2.5, 3.5, 5.5, 6.5, 8.5, 9.5, 11.5, 14.5, 15.5, 18.5, 20.5];

setappdata(0, 'frequencies', frequencies);
setappdata(0, 'fAtualizadas', frequencies);

setappdata(0, 'IDs', IDs);
setappdata(0, 'Data', quickPrimeTable);

setappdata(0, 'parametersData', data{4,1});
setappdata(0, 'hardwareLogData', data{2,1});
setappdata(0, 'logData', data{3,1});
setappdata(0, 'allExperimentData', data);

for i = 1 : length(IDs(1,:))
    strings_IDs{1,i} = num2str( IDs(1,i) );
end 

set(handles.escolhaEventID, 'string', strings_IDs);

% Retorna a datade realização do experimento
dateExperiment = HTA_getExperimentDate(data{2,1});

% Retorna o módulo de realização do experimento
module = HTA_getModuleCalibration(data{2,1});

% Parâmetros de calibração
cP = HTA_getCalibration(data{3,1});

% Verificação de Calibração
cS = HTA_verifyCalibration(module, cP);

Opt.Interpreter = 'tex';
Opt.WindowStyle = 'normal';

textCalibration = HTA_allowCalibration(cS);

msg = HTA_writeCalibrationMessage(cP, cS, dateExperiment);
h = msgbox (msg, 'Calibração do Experimento', 'none', Opt);
set(h, 'position', [100 0 300 450]);
set(h, 'Deletefcn', {@callback_CalibrationWarning, textCalibration, handles});

function callback_CalibrationWarning (hObject, eventdata, textCalibration, handles)
if ( ~textCalibration )
    error.f = figure('name', 'Cuidado!','units', 'pixels', 'position', [100 400 500 220], 'menu', 'none', 'toolbar', 'none', 'color',[0.9 0.9 0.9]);
    error.title = uicontrol ('style', 'text', 'units', 'pixels', 'position', [50 160 400 40], 'backgroundColor',[0.9 0.9 0.9], ...
        'string', 'Aviso!', 'fontunits', 'pixels', 'fontSize', 18, 'fontweight', 'bold', 'foregroundColor', [1 0 0]);
    error.txt = uicontrol ('style', 'text', 'fontSize', 10, 'units', 'pixels', 'position', [50 70 400 80], 'backgroundColor',[0.9 0.9 0.9], ...
        'string', {'A calibração deste experimento não está adequada!', 'A manipulação destes dados pode estar comprometida!', '', 'Deseja prosseguir?'});
    error.btnSim = uicontrol ('style', 'pushbutton', 'string', 'Sim', 'units', 'pixels', ...
        'position', [150 30 75 30], 'callback', {@callback_proceedingWrong, handles, error});
    error.btnNao = uicontrol ('style', 'pushbutton', 'string', 'Não', 'units', 'pixels', ...
        'position', [275 30 75 30], 'callback', {@callback_notProceedingWrong, error});    
else
    % --- Tomando os dados do experimento
    data = getappdata(0, 'allExperimentData');

    % --- Lendo os markers
    markers = HTA_findMarkers(data{4,1});
    setappdata(0, 'markers', markers);

    % --- n = Definindo quantidade de Markers
    tam = size(markers);
    n = tam(1);

    % --- Tomando os markersIDs
    for i=1:n
        markersID(i) = markers{i,1};
    end

    % --- Definindo altura da janela que os eventos markers
    windowHeight = 280 + 30*n;

    markerWindow.f = figure ('name', 'Definição de Markers', 'units', 'pixels', 'position', [250 250 400 windowHeight],...
                                'color',[0.9 0.9 0.9],'menu', 'none', 'toolbar', 'none');

    markerWindow.scriptName = uicontrol ('style', 'text', 'string', ['Script: ', HTA_getScriptName(data{4,1})], ...
                              'backgroundColor',[0.9 0.9 0.9], 'units', 'pixels', 'position', [100 windowHeight-60 200 30]);
                            
    markerWindow.tit = uicontrol ('style', 'text', 'string', 'Selecione os Markers abaixo:', ...
                                  'backgroundColor',[0.9 0.9 0.9], 'units', 'pixels', 'position', [100 windowHeight-90 200 30]);

    for i=1:n
        markerWindow.c(i) = uicontrol('style','checkbox','units','pixels','position',[50 windowHeight-90-30*(i) 300 30], ...
                                        'backgroundColor',[0.9 0.9 0.9], 'string', ['Evento ', num2str(markers{i, 1}), ': ', markers{i,2}]);
    end

    markerWindow.ask = uicontrol ('style', 'text', 'string', {'Deseja utilizar os eventos', 'selecionados como markers?'}, ...
                                  'backgroundColor',[0.9 0.9 0.9], 'units', 'pixels', 'position', [100 70 200 60]);

    markerWindow.btnSim = uicontrol('string', 'Sim', 'units', 'pixels', 'position', [110 30 75 30], 'callback', {@callback_buildMarks, markerWindow, markersID, handles} );
    markerWindow.btnNao = uicontrol('string', 'Não', 'units', 'pixels', 'position', [215 30 75 30], 'callback', {@callback_notBuildMarks, markerWindow, handles} );
end

function callback_notProceedingWrong (hObject, eventdata, error)
% --- Fechando a caixa de erro
close(error.f);

function callback_proceedingWrong (hObject, eventdata, handles, error)
% --- Colorindo o fundo das caixas de texto de vermelho
HTA_coloringBackgrounds(handles, 'red');

% --- Tomando os dados do experimento
data = getappdata(0, 'allExperimentData');

% --- Lendo os markers
markers = HTA_findMarkers(data{4,1});
setappdata(0, 'markers', markers);

% --- n = Definindo quantidade de Markers
tam = size(markers);
n = tam(1);

% --- Tomando os markersIDs
for i=1:n
    markersID(i) = markers{i,1};
end

% --- Definindo altura da janela que os eventos markers
windowHeight = 280 + 30*n;

markerWindow.f = figure ('name', 'Definição de Markers', 'units', 'pixels', 'position', [250 250 400 windowHeight],...
                            'color',[0.9 0.9 0.9],'menu', 'none', 'toolbar', 'none');

markerWindow.scriptName = uicontrol ('style', 'text', 'string', ['Script: ', HTA_getScriptName(data{4,1})], ...
                              'backgroundColor',[0.9 0.9 0.9], 'units', 'pixels', 'position', [100 windowHeight-60 200 30]);
                        
markerWindow.tit = uicontrol ('style', 'text', 'string', 'Selecione os Markers abaixo:', ...
                              'backgroundColor',[0.9 0.9 0.9], 'units', 'pixels', 'position', [100 windowHeight-90 200 30]);

for i=1:n
    markerWindow.c(i) = uicontrol('style','checkbox','units','pixels','position',[50 windowHeight-90-30*(i) 300 30], ...
                                    'backgroundColor',[0.9 0.9 0.9], 'string', ['Evento ', num2str(markers{i, 1}), ': ', markers{i,2}]);
end

markerWindow.ask = uicontrol ('style', 'text', 'string', {'Deseja utilizar os eventos', 'selecionados como markers?'}, ...
                              'backgroundColor',[0.9 0.9 0.9], 'units', 'pixels', 'position', [100 70 200 60]);

markerWindow.btnSim = uicontrol('string', 'Sim', 'units', 'pixels', 'position', [110 30 75 30], 'callback', {@callback_buildMarks, markerWindow, markersID, handles} );
markerWindow.btnNao = uicontrol('string', 'Não', 'units', 'pixels', 'position', [215 30 75 30], 'callback', {@callback_notBuildMarks, markerWindow, handles} );

% --- Fechando a caixa de erro
close(error.f);

function callback_notBuildMarks (hObject, eventdata, mW, handles)
    set(handles.escolhaEventID, 'visible', 'on');    
    close(mW.f);
    
function callback_buildMarks (hObject, eventdata, mW, markersID, handles)
    set(handles.escolhaEventID, 'visible', 'on');

    checkboxes = get(mW.c, 'value');
    checkboxes = cell2mat(checkboxes);
    checkboxes = checkboxes';

    markersID = markersID .* checkboxes;
    
    j = 0;
    copia=[];
    
    for k = 1 : length(markersID)
        if( markersID(k) ~= 0 )
            j = j+1;
            copia(j) = markersID(k);
        end
    end
    
    markersID = copia;
            
    setappdata (0, 'markersID', markersID);

    IDs = getappdata(0, 'IDs');

    for j=1:length(markersID)
        for i = 2:length(IDs)
           if( and( markersID(j) < abs(IDs(1,i)), markersID(j) > abs(IDs(1,i-1)) ) )
                indexMarkers(j) = i;
                break;
           end
        end
    end

    setappdata (0, 'markersIndex', indexMarkers);

    close(mW.f);

% --- Executes on selection change in escolhaEventID.
function escolhaEventID_Callback(hObject, eventdata, handles)
% Hints: contents = cellstr(get(hObject,'String')) returns escolhaEventID contents as cell array
%        contents{get(hObject,'Value')} returns selected item from escolhaEventID

data = getappdata(0, 'Data');

f = getappdata(0, 'frequencies');

% Retoma os ID's
IDs = getappdata(0, 'IDs');

% Verifica qual ID foi selecionado no drop_menu
selectedID_index = get(handles.escolhaEventID,'Value');
IDsCell = cellstr(get(handles.escolhaEventID,'String'));
selectedID = str2num( IDsCell{selectedID_index} );

% Retorna os valores da parte real e imaginaria do evento requisitado
realPart = HTA_getData(data, IDs, selectedID, 'Re(z)');
% Transforma coluna para linha
realPart = realPart';

setappdata(0, 'realPart', realPart);
setappdata(0, 'realPartAtualizada', realPart);

imaginaryPart = HTA_getData(data, IDs, selectedID, 'Im(z)');
% Transforma coluna para linha
imaginaryPart = imaginaryPart';

setappdata(0, 'imaginaryPart', imaginaryPart);
setappdata(0, 'imaginaryPartAtualizada', imaginaryPart);

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

msgbox(num2str(val^2));

setappdata(0, 'R', R);
setappdata(0, 'I', I);
setappdata(0, 'G', G);
setappdata(0, 'H', H);

set(handles.RField, 'string', R);
set(handles.IField, 'string', I);
set(handles.GField, 'string', G);
set(handles.HField, 'string', H);

% ------ Inserção dos parâmetros do arquivo Log

allData = getappdata (0, 'allExperimentData');
flexiVentParameters = HTA_getEventParameters ( allData, selectedID );

setappdata(0, 'flexiVentParameters', flexiVentParameters);

set(handles.RLogField, 'string', flexiVentParameters{1,1} );
set(handles.ILogField, 'string', flexiVentParameters{1,2} );
set(handles.GLogField, 'string', flexiVentParameters{1,3} );
set(handles.HLogField, 'string', flexiVentParameters{1,4} );
set(handles.CODLogField, 'string', flexiVentParameters{1,6} );
set(handles.R0LogField, 'string', flexiVentParameters{1,1} );
set(handles.I0LogField, 'string', flexiVentParameters{1,2} );
set(handles.G0LogField, 'string', flexiVentParameters{1,3} );
set(handles.H0LogField, 'string', flexiVentParameters{1,4} );

% ------ Calculo dos desvios

desvios = HTA_desvioParametros (constants, flexiVentParameters);

set(handles.desvioR, 'string', desvios{1,1} );
set(handles.desvioI, 'string', desvios{1,2} );
set(handles.desvioG, 'string', desvios{1,3} );
set(handles.desvioH, 'string', desvios{1,4} );

% ----- Calculo do Modelo

CPM = HTA_CPMCalculation (R, I, G, H, f);

setappdata(0, 'CPM', CPM);
setappdata(0, 'CPM0', CPM);

% ------ Plotando grafico

plot(handles.axes1,f, CPM{1,1}, 'k', f, CPM{1,2}, 'r', f,realPart,'kx',f,imaginaryPart,'k+', 'lineWidth', 2);    
set(handles.axes1,'xgrid','on','ygrid','on');
axes(handles.axes1);
title('Ajuste do modelo de fase constante à impedância respiratória');
legend('Z modelo Real ','Z modelo Imaginário ','Z calculado Real ','Z calculado Imaginário ','Location', 'southeast');


set(handles.fTable, 'data', HTA_buildFreqTable(realPart, imaginaryPart, CPM{1,1}, CPM{1,2}));

% --- Definicao dos Markers
markers = getappdata(0, 'markers');
markersID = getappdata(0, 'markersID');
markersIndex = getappdata(0, 'markersIndex');

if( ~isempty(markersID) )    
    if(abs(selectedID) >= markersID(1))
        for i = 1:length(markersID)
            if(abs(selectedID) >= markersID(i))
            	event = '';
                guideIndex = markersIndex(i);
                
                tam = size(markers);
                
                for k=1:tam(1)
                    event = markers{k,2};
                    
                    if(markers{k,1} == markersID(i))
                        break;
                    end
                end
            end
        end

        for j = guideIndex:length(IDs)
           if(selectedID == IDs(1, j))
               q = j-guideIndex+1;
               break;
           else
               q = 12345;
           end
        end
            
        set(handles.infoText, 'string', {[num2str(q), 'ª medida'], event});
        
    else
        set(handles.infoText, 'string', '');
    end
end

% --- Executes during object creation, after setting all properties.
function escolhaEventID_CreateFcn(hObject, eventdata, handles)
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function CODTextBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CODTextBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes on button press in f1.
function f1_Callback(hObject, eventdata, handles)
% Hint: get(hObject,'Value') returns toggle state of f1

value = get(handles.f1, 'Value');

f0 = getappdata(0, 'fAtualizadas');
f = getappdata(0, 'frequencies');

ImAtual = getappdata(0, 'imaginaryPartAtualizada');
imaginaryPart = getappdata(0, 'imaginaryPart');

RAtual = getappdata(0, 'realPartAtualizada');
realPart = getappdata(0, 'realPart');

if ( ~value )
    % Elimina-se a frequencia desmarcada
    f0(1) = 0;
    ImAtual(1) = 0;
    RAtual(1) = 0;
else
    f0(1) = 1.0;
    ImAtual(1) = imaginaryPart(1);
    RAtual(1) = realPart(1);
end

setappdata (0, 'fAtualizadas', f0);
setappdata(0, 'realPartAtualizada', RAtual);
setappdata(0, 'imaginaryPartAtualizada', ImAtual);

%--- Vetor de pontos retirados

j=0;
freqRetiradas = [];
realPart_retirada = [];
imPart_retirada = [];

for i=1:length(f0)
    if ( f0(i) == 0 )
        j = j+1;
        freqRetiradas(j) = f(i);
        realPart_retirada(j) = realPart(i);
        imPart_retirada(j) = imaginaryPart(i);
    end
end

%---- Retirando frequencias zeradas

f0 = f0(find(f0));
iPart = ImAtual(find(ImAtual));
rPart = RAtual(find(RAtual));


% ------ Calculo das novas constantes
% initialModelConstants = [R_inicial, I_inicial, G_inicial, H_inicial]
initialModelConstants = [0.2, 0.01, 5, 22];

% Definicao da funcao
func = @(constants)HTA_minSquareSum(constants,f0,rPart,iPart);

% Minimizando os valores das constantes do modelo
constants = fminsearch(func, initialModelConstants);

R0 = constants(1);
I0 = constants(2);
G0 = constants(3);
H0 = constants(4);

% ------ Escrita das constantes

set(handles.R0Field, 'string', R0);
set(handles.I0Field, 'string', I0);
set(handles.G0Field, 'string', G0);
set(handles.H0Field, 'string', H0);

% ----- Recuperando ID
% Verifica qual ID foi selecionado no drop_menu
selectedID_index = get(handles.escolhaEventID,'Value');
IDsCell = cellstr(get(handles.escolhaEventID,'String'));
selectedID = str2num( IDsCell{selectedID_index} );

% ------ Calculo dos desvios

flexiVentParameters = getappdata(0, 'flexiVentParameters');

desvios = HTA_desvioParametros (constants, flexiVentParameters);

set(handles.desvioR0, 'string', desvios{1,1} );
set(handles.desvioI0, 'string', desvios{1,2} );
set(handles.desvioG0, 'string', desvios{1,3} );
set(handles.desvioH0, 'string', desvios{1,4} );

% ----- Calculo dos Modelos

CPM0 = HTA_CPMCalculation (R0, I0, G0, H0, f);
CPM = getappdata(0, 'CPM');

% ------ Plotando grafico

HTA_plotarGrafico ( handles, CPM, CPM0, f, realPart, imaginaryPart, freqRetiradas, realPart_retirada, imPart_retirada );

% --- Executes on button press in f2.
function f2_Callback(hObject, eventdata, handles)
% Hint: get(hObject,'Value') returns toggle state of f2

value = get(handles.f2, 'Value');

f0 = getappdata(0, 'fAtualizadas');
f = getappdata(0, 'frequencies');

ImAtual = getappdata(0, 'imaginaryPartAtualizada');
imaginaryPart = getappdata(0, 'imaginaryPart');

RAtual = getappdata(0, 'realPartAtualizada');
realPart = getappdata(0, 'realPart');

if ( ~value )
    % Elimina-se a frequencia desmarcada
    f0(2) = 0;
    ImAtual(2) = 0;
    RAtual(2) = 0;
else
    f0(2) = 1.5;
    ImAtual(2) = imaginaryPart(2);
    RAtual(2) = realPart(2);
end

setappdata (0, 'fAtualizadas', f0);
setappdata(0, 'realPartAtualizada', RAtual);
setappdata(0, 'imaginaryPartAtualizada', ImAtual);

%--- Vetor de pontos retirados

j=0;
freqRetiradas = [];
realPart_retirada = [];
imPart_retirada = [];

for i=1:length(f0)
    if ( f0(i) == 0 )
        j = j+1;
        freqRetiradas(j) = f(i);
        realPart_retirada(j) = realPart(i);
        imPart_retirada(j) = imaginaryPart(i);
    end
end

%---- Retirando frequencias zeradas

f0 = f0(find(f0));
iPart = ImAtual(find(ImAtual));
rPart = RAtual(find(RAtual));


% ------ Calculo das novas constantes
% initialModelConstants = [R_inicial, I_inicial, G_inicial, H_inicial]
initialModelConstants = [0.2, 0.01, 5, 22];

% Definicao da funcao
func = @(constants)HTA_minSquareSum(constants,f0,rPart,iPart);

% Minimizando os valores das constantes do modelo
constants = fminsearch(func, initialModelConstants);

R0 = constants(1);
I0 = constants(2);
G0 = constants(3);
H0 = constants(4);

% ------ Escrita das constantes

set(handles.R0Field, 'string', R0);
set(handles.I0Field, 'string', I0);
set(handles.G0Field, 'string', G0);
set(handles.H0Field, 'string', H0);

% ----- Recuperando ID
% Verifica qual ID foi selecionado no drop_menu
selectedID_index = get(handles.escolhaEventID,'Value');
IDsCell = cellstr(get(handles.escolhaEventID,'String'));
selectedID = str2num( IDsCell{selectedID_index} );

% ------ Calculo dos desvios

flexiVentParameters = getappdata(0, 'flexiVentParameters');

desvios = HTA_desvioParametros (constants, flexiVentParameters);

set(handles.desvioR0, 'string', desvios{1,1} );
set(handles.desvioI0, 'string', desvios{1,2} );
set(handles.desvioG0, 'string', desvios{1,3} );
set(handles.desvioH0, 'string', desvios{1,4} );

% ----- Calculo dos Modelos

CPM0 = HTA_CPMCalculation (R0, I0, G0, H0, f);
CPM = getappdata(0, 'CPM');

% ------ Plotando grafico

HTA_plotarGrafico ( handles, CPM, CPM0, f, realPart, imaginaryPart, freqRetiradas, realPart_retirada, imPart_retirada );

% --- Executes on button press in f3.
function f3_Callback(hObject, eventdata, handles)
% Hint: get(hObject,'Value') returns toggle state of f3

value = get(handles.f3, 'Value');

f0 = getappdata(0, 'fAtualizadas');
f = getappdata(0, 'frequencies');

ImAtual = getappdata(0, 'imaginaryPartAtualizada');
imaginaryPart = getappdata(0, 'imaginaryPart');

RAtual = getappdata(0, 'realPartAtualizada');
realPart = getappdata(0, 'realPart');

if ( ~value )
    % Elimina-se a frequencia desmarcada
    f0(3) = 0;
    ImAtual(3) = 0;
    RAtual(3) = 0;
else
    f0(3) = 2.5;
    ImAtual(3) = imaginaryPart(3);
    RAtual(3) = realPart(3);
end

setappdata (0, 'fAtualizadas', f0);
setappdata(0, 'realPartAtualizada', RAtual);
setappdata(0, 'imaginaryPartAtualizada', ImAtual);

%--- Vetor de pontos retirados

j=0;
freqRetiradas = [];
realPart_retirada = [];
imPart_retirada = [];

for i=1:length(f0)
    if ( f0(i) == 0 )
        j = j+1;
        freqRetiradas(j) = f(i);
        realPart_retirada(j) = realPart(i);
        imPart_retirada(j) = imaginaryPart(i);
    end
end

%---- Retirando frequencias zeradas

f0 = f0(find(f0));
iPart = ImAtual(find(ImAtual));
rPart = RAtual(find(RAtual));

% ------ Calculo das novas constantes
% initialModelConstants = [R_inicial, I_inicial, G_inicial, H_inicial]
initialModelConstants = [0.2, 0.01, 5, 22];

% Definicao da funcao
func = @(constants)HTA_minSquareSum(constants,f0,rPart,iPart);

% Minimizando os valores das constantes do modelo
constants = fminsearch(func, initialModelConstants);

R0 = constants(1);
I0 = constants(2);
G0 = constants(3);
H0 = constants(4);

% ------ Escrita das constantes

set(handles.R0Field, 'string', R0);
set(handles.I0Field, 'string', I0);
set(handles.G0Field, 'string', G0);
set(handles.H0Field, 'string', H0);

% ----- Recuperando ID
% Verifica qual ID foi selecionado no drop_menu
selectedID_index = get(handles.escolhaEventID,'Value');
IDsCell = cellstr(get(handles.escolhaEventID,'String'));
selectedID = str2num( IDsCell{selectedID_index} );

% ------ Calculo dos desvios

flexiVentParameters = getappdata(0, 'flexiVentParameters');

desvios = HTA_desvioParametros (constants, flexiVentParameters);

set(handles.desvioR0, 'string', desvios{1,1} );
set(handles.desvioI0, 'string', desvios{1,2} );
set(handles.desvioG0, 'string', desvios{1,3} );
set(handles.desvioH0, 'string', desvios{1,4} );

% ----- Calculo dos Modelos

CPM0 = HTA_CPMCalculation (R0, I0, G0, H0, f);
CPM = getappdata(0, 'CPM');

% ------ Plotando grafico

HTA_plotarGrafico ( handles, CPM, CPM0, f, realPart, imaginaryPart, freqRetiradas, realPart_retirada, imPart_retirada );

% --- Executes on button press in f4.
function f4_Callback(hObject, eventdata, handles)
% Hint: get(hObject,'Value') returns toggle state of f4

value = get(handles.f4, 'Value');

f0 = getappdata(0, 'fAtualizadas');
f = getappdata(0, 'frequencies');

ImAtual = getappdata(0, 'imaginaryPartAtualizada');
imaginaryPart = getappdata(0, 'imaginaryPart');

RAtual = getappdata(0, 'realPartAtualizada');
realPart = getappdata(0, 'realPart');

if ( ~value )
    % Elimina-se a frequencia desmarcada
    f0(4) = 0;
    ImAtual(4) = 0;
    RAtual(4) = 0;
else
    f0(4) = 3.5;
    ImAtual(4) = imaginaryPart(4);
    RAtual(4) = realPart(4);
end

setappdata (0, 'fAtualizadas', f0);
setappdata(0, 'realPartAtualizada', RAtual);
setappdata(0, 'imaginaryPartAtualizada', ImAtual);

%--- Vetor de pontos retirados

j=0;
freqRetiradas = [];
realPart_retirada = [];
imPart_retirada = [];

for i=1:length(f0)
    if ( f0(i) == 0 )
        j = j+1;
        freqRetiradas(j) = f(i);
        realPart_retirada(j) = realPart(i);
        imPart_retirada(j) = imaginaryPart(i);
    end
end

%---- Retirando frequencias zeradas

f0 = f0(find(f0));
iPart = ImAtual(find(ImAtual));
rPart = RAtual(find(RAtual));


% ------ Calculo das novas constantes
% initialModelConstants = [R_inicial, I_inicial, G_inicial, H_inicial]
initialModelConstants = [0.2, 0.01, 5, 22];

% Definicao da funcao
func = @(constants)HTA_minSquareSum(constants,f0,rPart,iPart);

% Minimizando os valores das constantes do modelo
constants = fminsearch(func, initialModelConstants);

R0 = constants(1);
I0 = constants(2);
G0 = constants(3);
H0 = constants(4);

% ------ Escrita das constantes

set(handles.R0Field, 'string', R0);
set(handles.I0Field, 'string', I0);
set(handles.G0Field, 'string', G0);
set(handles.H0Field, 'string', H0);

% ----- Recuperando ID
% Verifica qual ID foi selecionado no drop_menu
selectedID_index = get(handles.escolhaEventID,'Value');
IDsCell = cellstr(get(handles.escolhaEventID,'String'));
selectedID = str2num( IDsCell{selectedID_index} );

% ------ Calculo dos desvios

flexiVentParameters = getappdata(0, 'flexiVentParameters');

desvios = HTA_desvioParametros (constants, flexiVentParameters);

set(handles.desvioR0, 'string', desvios{1,1} );
set(handles.desvioI0, 'string', desvios{1,2} );
set(handles.desvioG0, 'string', desvios{1,3} );
set(handles.desvioH0, 'string', desvios{1,4} );

% ----- Calculo dos Modelos

CPM0 = HTA_CPMCalculation (R0, I0, G0, H0, f);
CPM = getappdata(0, 'CPM');

% ------ Plotando grafico

HTA_plotarGrafico ( handles, CPM, CPM0, f, realPart, imaginaryPart, freqRetiradas, realPart_retirada, imPart_retirada );

% --- Executes on button press in f5.
function f5_Callback(hObject, eventdata, handles)
% Hint: get(hObject,'Value') returns toggle state of f5

value = get(handles.f5, 'Value');

f0 = getappdata(0, 'fAtualizadas');
f = getappdata(0, 'frequencies');

ImAtual = getappdata(0, 'imaginaryPartAtualizada');
imaginaryPart = getappdata(0, 'imaginaryPart');

RAtual = getappdata(0, 'realPartAtualizada');
realPart = getappdata(0, 'realPart');

if ( ~value )
    % Elimina-se a frequencia desmarcada
    f0(5) = 0;
    ImAtual(5) = 0;
    RAtual(5) = 0;
else
    f0(5) = 5.5;
    ImAtual(5) = imaginaryPart(5);
    RAtual(5) = realPart(5);
end

setappdata (0, 'fAtualizadas', f0);
setappdata(0, 'realPartAtualizada', RAtual);
setappdata(0, 'imaginaryPartAtualizada', ImAtual);

%--- Vetor de pontos retirados

j=0;
freqRetiradas = [];
realPart_retirada = [];
imPart_retirada = [];

for i=1:length(f0)
    if ( f0(i) == 0 )
        j = j+1;
        freqRetiradas(j) = f(i);
        realPart_retirada(j) = realPart(i);
        imPart_retirada(j) = imaginaryPart(i);
    end
end

%---- Retirando frequencias zeradas

f0 = f0(find(f0));
iPart = ImAtual(find(ImAtual));
rPart = RAtual(find(RAtual));


% ------ Calculo das novas constantes
% initialModelConstants = [R_inicial, I_inicial, G_inicial, H_inicial]
initialModelConstants = [0.2, 0.01, 5, 22];

% Definicao da funcao
func = @(constants)HTA_minSquareSum(constants,f0,rPart,iPart);

% Minimizando os valores das constantes do modelo
constants = fminsearch(func, initialModelConstants);

R0 = constants(1);
I0 = constants(2);
G0 = constants(3);
H0 = constants(4);

% ------ Escrita das constantes

set(handles.R0Field, 'string', R0);
set(handles.I0Field, 'string', I0);
set(handles.G0Field, 'string', G0);
set(handles.H0Field, 'string', H0);

% ----- Recuperando ID
% Verifica qual ID foi selecionado no drop_menu
selectedID_index = get(handles.escolhaEventID,'Value');
IDsCell = cellstr(get(handles.escolhaEventID,'String'));
selectedID = str2num( IDsCell{selectedID_index} );

% ------ Calculo dos desvios

flexiVentParameters = getappdata(0, 'flexiVentParameters');

desvios = HTA_desvioParametros (constants, flexiVentParameters);

set(handles.desvioR0, 'string', desvios{1,1} );
set(handles.desvioI0, 'string', desvios{1,2} );
set(handles.desvioG0, 'string', desvios{1,3} );
set(handles.desvioH0, 'string', desvios{1,4} );

% ----- Calculo dos Modelos

CPM0 = HTA_CPMCalculation (R0, I0, G0, H0, f);
CPM = getappdata(0, 'CPM');

% ------ Plotando grafico

HTA_plotarGrafico ( handles, CPM, CPM0, f, realPart, imaginaryPart, freqRetiradas, realPart_retirada, imPart_retirada );

% --- Executes on button press in f6.
function f6_Callback(hObject, eventdata, handles)
% Hint: get(hObject,'Value') returns toggle state of f6

value = get(handles.f6, 'Value');

f0 = getappdata(0, 'fAtualizadas');
f = getappdata(0, 'frequencies');

ImAtual = getappdata(0, 'imaginaryPartAtualizada');
imaginaryPart = getappdata(0, 'imaginaryPart');

RAtual = getappdata(0, 'realPartAtualizada');
realPart = getappdata(0, 'realPart');

if ( ~value )
    % Elimina-se a frequencia desmarcada
    f0(6) = 0;
    ImAtual(6) = 0;
    RAtual(6) = 0;
else
    f0(6) = 6.5;
    ImAtual(6) = imaginaryPart(6);
    RAtual(6) = realPart(6);
end

setappdata (0, 'fAtualizadas', f0);
setappdata(0, 'realPartAtualizada', RAtual);
setappdata(0, 'imaginaryPartAtualizada', ImAtual);

%--- Vetor de pontos retirados

j=0;
freqRetiradas = [];
realPart_retirada = [];
imPart_retirada = [];

for i=1:length(f0)
    if ( f0(i) == 0 )
        j = j+1;
        freqRetiradas(j) = f(i);
        realPart_retirada(j) = realPart(i);
        imPart_retirada(j) = imaginaryPart(i);
    end
end

%---- Retirando frequencias zeradas

f0 = f0(find(f0));
iPart = ImAtual(find(ImAtual));
rPart = RAtual(find(RAtual));


% ------ Calculo das novas constantes
% initialModelConstants = [R_inicial, I_inicial, G_inicial, H_inicial]
initialModelConstants = [0.2, 0.01, 5, 22];

% Definicao da funcao
func = @(constants)HTA_minSquareSum(constants,f0,rPart,iPart);

% Minimizando os valores das constantes do modelo
constants = fminsearch(func, initialModelConstants);

R0 = constants(1);
I0 = constants(2);
G0 = constants(3);
H0 = constants(4);

% ------ Escrita das constantes

set(handles.R0Field, 'string', R0);
set(handles.I0Field, 'string', I0);
set(handles.G0Field, 'string', G0);
set(handles.H0Field, 'string', H0);

% ----- Recuperando ID
% Verifica qual ID foi selecionado no drop_menu
selectedID_index = get(handles.escolhaEventID,'Value');
IDsCell = cellstr(get(handles.escolhaEventID,'String'));
selectedID = str2num( IDsCell{selectedID_index} );

% ------ Calculo dos desvios

flexiVentParameters = getappdata(0, 'flexiVentParameters');

desvios = HTA_desvioParametros (constants, flexiVentParameters);

set(handles.desvioR0, 'string', desvios{1,1} );
set(handles.desvioI0, 'string', desvios{1,2} );
set(handles.desvioG0, 'string', desvios{1,3} );
set(handles.desvioH0, 'string', desvios{1,4} );

% ----- Calculo dos Modelos

CPM0 = HTA_CPMCalculation (R0, I0, G0, H0, f);
CPM = getappdata(0, 'CPM');

% ------ Plotando grafico

HTA_plotarGrafico ( handles, CPM, CPM0, f, realPart, imaginaryPart, freqRetiradas, realPart_retirada, imPart_retirada );

% --- Executes on button press in f7.
function f7_Callback(hObject, eventdata, handles)
% Hint: get(hObject,'Value') returns toggle state of f7

value = get(handles.f7, 'Value');

f0 = getappdata(0, 'fAtualizadas');
f = getappdata(0, 'frequencies');

ImAtual = getappdata(0, 'imaginaryPartAtualizada');
imaginaryPart = getappdata(0, 'imaginaryPart');

RAtual = getappdata(0, 'realPartAtualizada');
realPart = getappdata(0, 'realPart');

if ( ~value )
    % Elimina-se a frequencia desmarcada
    f0(7) = 0;
    ImAtual(7) = 0;
    RAtual(7) = 0;
else
    f0(7) = 8.5;
    ImAtual(7) = imaginaryPart(7);
    RAtual(7) = realPart(7);
end

setappdata (0, 'fAtualizadas', f0);
setappdata(0, 'realPartAtualizada', RAtual);
setappdata(0, 'imaginaryPartAtualizada', ImAtual);

%--- Vetor de pontos retirados

j=0;
freqRetiradas = [];
realPart_retirada = [];
imPart_retirada = [];

for i=1:length(f0)
    if ( f0(i) == 0 )
        j = j+1;
        freqRetiradas(j) = f(i);
        realPart_retirada(j) = realPart(i);
        imPart_retirada(j) = imaginaryPart(i);
    end
end

%---- Retirando frequencias zeradas

f0 = f0(find(f0));
iPart = ImAtual(find(ImAtual));
rPart = RAtual(find(RAtual));


% ------ Calculo das novas constantes
% initialModelConstants = [R_inicial, I_inicial, G_inicial, H_inicial]
initialModelConstants = [0.2, 0.01, 5, 22];

% Definicao da funcao
func = @(constants)HTA_minSquareSum(constants,f0,rPart,iPart);

% Minimizando os valores das constantes do modelo
constants = fminsearch(func, initialModelConstants);

R0 = constants(1);
I0 = constants(2);
G0 = constants(3);
H0 = constants(4);

% ------ Escrita das constantes

set(handles.R0Field, 'string', R0);
set(handles.I0Field, 'string', I0);
set(handles.G0Field, 'string', G0);
set(handles.H0Field, 'string', H0);

% ----- Recuperando ID
% Verifica qual ID foi selecionado no drop_menu
selectedID_index = get(handles.escolhaEventID,'Value');
IDsCell = cellstr(get(handles.escolhaEventID,'String'));
selectedID = str2num( IDsCell{selectedID_index} );

% ------ Calculo dos desvios

flexiVentParameters = getappdata(0, 'flexiVentParameters');

desvios = HTA_desvioParametros (constants, flexiVentParameters);

set(handles.desvioR0, 'string', desvios{1,1} );
set(handles.desvioI0, 'string', desvios{1,2} );
set(handles.desvioG0, 'string', desvios{1,3} );
set(handles.desvioH0, 'string', desvios{1,4} );

% ----- Calculo dos Modelos

CPM0 = HTA_CPMCalculation (R0, I0, G0, H0, f);
CPM = getappdata(0, 'CPM');

% ------ Plotando grafico

HTA_plotarGrafico ( handles, CPM, CPM0, f, realPart, imaginaryPart, freqRetiradas, realPart_retirada, imPart_retirada );

% --- Executes on button press in f8.
function f8_Callback(hObject, eventdata, handles)
% Hint: get(hObject,'Value') returns toggle state of f8

value = get(handles.f8, 'Value');

f0 = getappdata(0, 'fAtualizadas');
f = getappdata(0, 'frequencies');

ImAtual = getappdata(0, 'imaginaryPartAtualizada');
imaginaryPart = getappdata(0, 'imaginaryPart');

RAtual = getappdata(0, 'realPartAtualizada');
realPart = getappdata(0, 'realPart');

if ( ~value )
    % Elimina-se a frequencia desmarcada
    f0(8) = 0;
    ImAtual(8) = 0;
    RAtual(8) = 0;
else
    f0(8) = 9.5;
    ImAtual(8) = imaginaryPart(8);
    RAtual(8) = realPart(8);
end

setappdata (0, 'fAtualizadas', f0);
setappdata(0, 'realPartAtualizada', RAtual);
setappdata(0, 'imaginaryPartAtualizada', ImAtual);

%--- Vetor de pontos retirados

j=0;
freqRetiradas = [];
realPart_retirada = [];
imPart_retirada = [];

for i=1:length(f0)
    if ( f0(i) == 0 )
        j = j+1;
        freqRetiradas(j) = f(i);
        realPart_retirada(j) = realPart(i);
        imPart_retirada(j) = imaginaryPart(i);
    end
end

%---- Retirando frequencias zeradas

f0 = f0(find(f0));
iPart = ImAtual(find(ImAtual));
rPart = RAtual(find(RAtual));


% ------ Calculo das novas constantes
% initialModelConstants = [R_inicial, I_inicial, G_inicial, H_inicial]
initialModelConstants = [0.2, 0.01, 5, 22];

% Definicao da funcao
func = @(constants)HTA_minSquareSum(constants,f0,rPart,iPart);

% Minimizando os valores das constantes do modelo
constants = fminsearch(func, initialModelConstants);

R0 = constants(1);
I0 = constants(2);
G0 = constants(3);
H0 = constants(4);

% ------ Escrita das constantes

set(handles.R0Field, 'string', R0);
set(handles.I0Field, 'string', I0);
set(handles.G0Field, 'string', G0);
set(handles.H0Field, 'string', H0);

% ----- Recuperando ID
% Verifica qual ID foi selecionado no drop_menu
selectedID_index = get(handles.escolhaEventID,'Value');
IDsCell = cellstr(get(handles.escolhaEventID,'String'));
selectedID = str2num( IDsCell{selectedID_index} );

% ------ Calculo dos desvios

flexiVentParameters = getappdata(0, 'flexiVentParameters');

desvios = HTA_desvioParametros (constants, flexiVentParameters);

set(handles.desvioR0, 'string', desvios{1,1} );
set(handles.desvioI0, 'string', desvios{1,2} );
set(handles.desvioG0, 'string', desvios{1,3} );
set(handles.desvioH0, 'string', desvios{1,4} );

% ----- Calculo dos Modelos

CPM0 = HTA_CPMCalculation (R0, I0, G0, H0, f);
CPM = getappdata(0, 'CPM');

% ------ Plotando grafico

HTA_plotarGrafico ( handles, CPM, CPM0, f, realPart, imaginaryPart, freqRetiradas, realPart_retirada, imPart_retirada );

% --- Executes on button press in f9.
function f9_Callback(hObject, eventdata, handles)
% Hint: get(hObject,'Value') returns toggle state of f9

value = get(handles.f9, 'Value');

f0 = getappdata(0, 'fAtualizadas');
f = getappdata(0, 'frequencies');

ImAtual = getappdata(0, 'imaginaryPartAtualizada');
imaginaryPart = getappdata(0, 'imaginaryPart');

RAtual = getappdata(0, 'realPartAtualizada');
realPart = getappdata(0, 'realPart');

if ( ~value )
    % Elimina-se a frequencia desmarcada
    f0(9) = 0;
    ImAtual(9) = 0;
    RAtual(9) = 0;
else
    f0(9) = 11.5;
    ImAtual(9) = imaginaryPart(9);
    RAtual(9) = realPart(9);
end

setappdata (0, 'fAtualizadas', f0);
setappdata(0, 'realPartAtualizada', RAtual);
setappdata(0, 'imaginaryPartAtualizada', ImAtual);

%--- Vetor de pontos retirados

j=0;
freqRetiradas = [];
realPart_retirada = [];
imPart_retirada = [];

for i=1:length(f0)
    if ( f0(i) == 0 )
        j = j+1;
        freqRetiradas(j) = f(i);
        realPart_retirada(j) = realPart(i);
        imPart_retirada(j) = imaginaryPart(i);
    end
end

%---- Retirando frequencias zeradas

f0 = f0(find(f0));
iPart = ImAtual(find(ImAtual));
rPart = RAtual(find(RAtual));


% ------ Calculo das novas constantes
% initialModelConstants = [R_inicial, I_inicial, G_inicial, H_inicial]
initialModelConstants = [0.2, 0.01, 5, 22];

% Definicao da funcao
func = @(constants)HTA_minSquareSum(constants,f0,rPart,iPart);

% Minimizando os valores das constantes do modelo
constants = fminsearch(func, initialModelConstants);

R0 = constants(1);
I0 = constants(2);
G0 = constants(3);
H0 = constants(4);

% ------ Escrita das constantes

set(handles.R0Field, 'string', R0);
set(handles.I0Field, 'string', I0);
set(handles.G0Field, 'string', G0);
set(handles.H0Field, 'string', H0);

% ----- Recuperando ID
% Verifica qual ID foi selecionado no drop_menu
selectedID_index = get(handles.escolhaEventID,'Value');
IDsCell = cellstr(get(handles.escolhaEventID,'String'));
selectedID = str2num( IDsCell{selectedID_index} );

% ------ Calculo dos desvios

flexiVentParameters = getappdata(0, 'flexiVentParameters');

desvios = HTA_desvioParametros (constants, flexiVentParameters);

set(handles.desvioR0, 'string', desvios{1,1} );
set(handles.desvioI0, 'string', desvios{1,2} );
set(handles.desvioG0, 'string', desvios{1,3} );
set(handles.desvioH0, 'string', desvios{1,4} );

% ----- Calculo dos Modelos

CPM0 = HTA_CPMCalculation (R0, I0, G0, H0, f);
CPM = getappdata(0, 'CPM');

% ------ Plotando grafico

HTA_plotarGrafico ( handles, CPM, CPM0, f, realPart, imaginaryPart, freqRetiradas, realPart_retirada, imPart_retirada );

% --- Executes on button press in f10.
function f10_Callback(hObject, eventdata, handles)
% Hint: get(hObject,'Value') returns toggle state of f10

value = get(handles.f10, 'Value');

f0 = getappdata(0, 'fAtualizadas');
f = getappdata(0, 'frequencies');

ImAtual = getappdata(0, 'imaginaryPartAtualizada');
imaginaryPart = getappdata(0, 'imaginaryPart');

RAtual = getappdata(0, 'realPartAtualizada');
realPart = getappdata(0, 'realPart');

if ( ~value )
    % Elimina-se a frequencia desmarcada
    f0(10) = 0;
    ImAtual(10) = 0;
    RAtual(10) = 0;
else
    f0(10) = 14.5;
    ImAtual(10) = imaginaryPart(10);
    RAtual(10) = realPart(10);
end

setappdata (0, 'fAtualizadas', f0);
setappdata(0, 'realPartAtualizada', RAtual);
setappdata(0, 'imaginaryPartAtualizada', ImAtual);

%--- Vetor de pontos retirados

j=0;
freqRetiradas = [];
realPart_retirada = [];
imPart_retirada = [];

for i=1:length(f0)
    if ( f0(i) == 0 )
        j = j+1;
        freqRetiradas(j) = f(i);
        realPart_retirada(j) = realPart(i);
        imPart_retirada(j) = imaginaryPart(i);
    end
end

%---- Retirando frequencias zeradas

f0 = f0(find(f0));
iPart = ImAtual(find(ImAtual));
rPart = RAtual(find(RAtual));


% ------ Calculo das novas constantes
% initialModelConstants = [R_inicial, I_inicial, G_inicial, H_inicial]
initialModelConstants = [0.2, 0.01, 5, 22];

% Definicao da funcao
func = @(constants)HTA_minSquareSum(constants,f0,rPart,iPart);

% Minimizando os valores das constantes do modelo
constants = fminsearch(func, initialModelConstants);

R0 = constants(1);
I0 = constants(2);
G0 = constants(3);
H0 = constants(4);

% ------ Escrita das constantes

set(handles.R0Field, 'string', R0);
set(handles.I0Field, 'string', I0);
set(handles.G0Field, 'string', G0);
set(handles.H0Field, 'string', H0);

% ----- Recuperando ID
% Verifica qual ID foi selecionado no drop_menu
selectedID_index = get(handles.escolhaEventID,'Value');
IDsCell = cellstr(get(handles.escolhaEventID,'String'));
selectedID = str2num( IDsCell{selectedID_index} );

% ------ Calculo dos desvios

flexiVentParameters = getappdata(0, 'flexiVentParameters');

desvios = HTA_desvioParametros (constants, flexiVentParameters);

set(handles.desvioR0, 'string', desvios{1,1} );
set(handles.desvioI0, 'string', desvios{1,2} );
set(handles.desvioG0, 'string', desvios{1,3} );
set(handles.desvioH0, 'string', desvios{1,4} );

% ----- Calculo dos Modelos

CPM0 = HTA_CPMCalculation (R0, I0, G0, H0, f);
CPM = getappdata(0, 'CPM');

% ------ Plotando grafico

HTA_plotarGrafico ( handles, CPM, CPM0, f, realPart, imaginaryPart, freqRetiradas, realPart_retirada, imPart_retirada );

% --- Executes on button press in f11.
function f11_Callback(hObject, eventdata, handles)
% Hint: get(hObject,'Value') returns toggle state of f11

value = get(handles.f11, 'Value');

f0 = getappdata(0, 'fAtualizadas');
f = getappdata(0, 'frequencies');

ImAtual = getappdata(0, 'imaginaryPartAtualizada');
imaginaryPart = getappdata(0, 'imaginaryPart');

RAtual = getappdata(0, 'realPartAtualizada');
realPart = getappdata(0, 'realPart');

if ( ~value )
    % Elimina-se a frequencia desmarcada
    f0(11) = 0;
    ImAtual(11) = 0;
    RAtual(11) = 0;
else
    f0(11) = 15.5;
    ImAtual(11) = imaginaryPart(11);
    RAtual(11) = realPart(11);
end

setappdata (0, 'fAtualizadas', f0);
setappdata(0, 'realPartAtualizada', RAtual);
setappdata(0, 'imaginaryPartAtualizada', ImAtual);

%--- Vetor de pontos retirados

j=0;
freqRetiradas = [];
realPart_retirada = [];
imPart_retirada = [];

for i=1:length(f0)
    if ( f0(i) == 0 )
        j = j+1;
        freqRetiradas(j) = f(i);
        realPart_retirada(j) = realPart(i);
        imPart_retirada(j) = imaginaryPart(i);
    end
end

%---- Retirando frequencias zeradas

f0 = f0(find(f0));
iPart = ImAtual(find(ImAtual));
rPart = RAtual(find(RAtual));


% ------ Calculo das novas constantes
% initialModelConstants = [R_inicial, I_inicial, G_inicial, H_inicial]
initialModelConstants = [0.2, 0.01, 5, 22];

% Definicao da funcao
func = @(constants)HTA_minSquareSum(constants,f0,rPart,iPart);

% Minimizando os valores das constantes do modelo
constants = fminsearch(func, initialModelConstants);

R0 = constants(1);
I0 = constants(2);
G0 = constants(3);
H0 = constants(4);

% ------ Escrita das constantes

set(handles.R0Field, 'string', R0);
set(handles.I0Field, 'string', I0);
set(handles.G0Field, 'string', G0);
set(handles.H0Field, 'string', H0);

% ----- Recuperando ID
% Verifica qual ID foi selecionado no drop_menu
selectedID_index = get(handles.escolhaEventID,'Value');
IDsCell = cellstr(get(handles.escolhaEventID,'String'));
selectedID = str2num( IDsCell{selectedID_index} );

% ------ Calculo dos desvios

flexiVentParameters = getappdata(0, 'flexiVentParameters');

desvios = HTA_desvioParametros (constants, flexiVentParameters);

set(handles.desvioR0, 'string', desvios{1,1} );
set(handles.desvioI0, 'string', desvios{1,2} );
set(handles.desvioG0, 'string', desvios{1,3} );
set(handles.desvioH0, 'string', desvios{1,4} );

% ----- Calculo dos Modelos

CPM0 = HTA_CPMCalculation (R0, I0, G0, H0, f);
CPM = getappdata(0, 'CPM');

% ------ Plotando grafico

HTA_plotarGrafico ( handles, CPM, CPM0, f, realPart, imaginaryPart, freqRetiradas, realPart_retirada, imPart_retirada );

% --- Executes on button press in f12.
function f12_Callback(hObject, eventdata, handles)
% Hint: get(hObject,'Value') returns toggle state of f12

value = get(handles.f12, 'Value');

f0 = getappdata(0, 'fAtualizadas');
f = getappdata(0, 'frequencies');

ImAtual = getappdata(0, 'imaginaryPartAtualizada');
imaginaryPart = getappdata(0, 'imaginaryPart');

RAtual = getappdata(0, 'realPartAtualizada');
realPart = getappdata(0, 'realPart');

if ( ~value )
    % Elimina-se a frequencia desmarcada
    f0(12) = 0;
    ImAtual(12) = 0;
    RAtual(12) = 0;
else
    f0(12) = 18.5;
    ImAtual(12) = imaginaryPart(12);
    RAtual(12) = realPart(12);
end

setappdata (0, 'fAtualizadas', f0);
setappdata(0, 'realPartAtualizada', RAtual);
setappdata(0, 'imaginaryPartAtualizada', ImAtual);

%--- Vetor de pontos retirados

j=0;
freqRetiradas = [];
realPart_retirada = [];
imPart_retirada = [];

for i=1:length(f0)
    if ( f0(i) == 0 )
        j = j+1;
        freqRetiradas(j) = f(i);
        realPart_retirada(j) = realPart(i);
        imPart_retirada(j) = imaginaryPart(i);
    end
end

%---- Retirando frequencias zeradas

f0 = f0(find(f0));
iPart = ImAtual(find(ImAtual));
rPart = RAtual(find(RAtual));


% ------ Calculo das novas constantes
% initialModelConstants = [R_inicial, I_inicial, G_inicial, H_inicial]
initialModelConstants = [0.2, 0.01, 5, 22];

% Definicao da funcao
func = @(constants)HTA_minSquareSum(constants,f0,rPart,iPart);

% Minimizando os valores das constantes do modelo
constants = fminsearch(func, initialModelConstants);

R0 = constants(1);
I0 = constants(2);
G0 = constants(3);
H0 = constants(4);

% ------ Escrita das constantes

set(handles.R0Field, 'string', R0);
set(handles.I0Field, 'string', I0);
set(handles.G0Field, 'string', G0);
set(handles.H0Field, 'string', H0);

% ----- Recuperando ID
% Verifica qual ID foi selecionado no drop_menu
selectedID_index = get(handles.escolhaEventID,'Value');
IDsCell = cellstr(get(handles.escolhaEventID,'String'));
selectedID = str2num( IDsCell{selectedID_index} );

% ------ Calculo dos desvios

flexiVentParameters = getappdata(0, 'flexiVentParameters');

desvios = HTA_desvioParametros (constants, flexiVentParameters);

set(handles.desvioR0, 'string', desvios{1,1} );
set(handles.desvioI0, 'string', desvios{1,2} );
set(handles.desvioG0, 'string', desvios{1,3} );
set(handles.desvioH0, 'string', desvios{1,4} );

% ----- Calculo dos Modelos

CPM0 = HTA_CPMCalculation (R0, I0, G0, H0, f);
CPM = getappdata(0, 'CPM');

% ------ Plotando grafico

HTA_plotarGrafico ( handles, CPM, CPM0, f, realPart, imaginaryPart, freqRetiradas, realPart_retirada, imPart_retirada );

% --- Executes on button press in f13.
function f13_Callback(hObject, eventdata, handles)
% Hint: get(hObject,'Value') returns toggle state of f13

value = get(handles.f13, 'Value');

f0 = getappdata(0, 'fAtualizadas');
f = getappdata(0, 'frequencies');

ImAtual = getappdata(0, 'imaginaryPartAtualizada');
imaginaryPart = getappdata(0, 'imaginaryPart');

RAtual = getappdata(0, 'realPartAtualizada');
realPart = getappdata(0, 'realPart');

if ( ~value )
    % Elimina-se a frequencia desmarcada
    f0(13) = 0;
    ImAtual(13) = 0;
    RAtual(13) = 0;
else
    f0(13) = 20.5;
    ImAtual(13) = imaginaryPart(13);
    RAtual(13) = realPart(13);
end

setappdata (0, 'fAtualizadas', f0);
setappdata(0, 'realPartAtualizada', RAtual);
setappdata(0, 'imaginaryPartAtualizada', ImAtual);

%--- Vetor de pontos retirados

j=0;
freqRetiradas = [];
realPart_retirada = [];
imPart_retirada = [];

for i=1:length(f0)
    if ( f0(i) == 0 )
        j = j+1;
        freqRetiradas(j) = f(i);
        realPart_retirada(j) = realPart(i);
        imPart_retirada(j) = imaginaryPart(i);
    end
end

%---- Retirando frequencias zeradas

f0 = f0(find(f0));
iPart = ImAtual(find(ImAtual));
rPart = RAtual(find(RAtual));


% ------ Calculo das novas constantes
% initialModelConstants = [R_inicial, I_inicial, G_inicial, H_inicial]
initialModelConstants = [0.2, 0.01, 5, 22];

% Definicao da funcao
func = @(constants)HTA_minSquareSum(constants,f0,rPart,iPart);

% Minimizando os valores das constantes do modelo
constants = fminsearch(func, initialModelConstants);

R0 = constants(1);
I0 = constants(2);
G0 = constants(3);
H0 = constants(4);

% ------ Escrita das constantes

set(handles.R0Field, 'string', R0);
set(handles.I0Field, 'string', I0);
set(handles.G0Field, 'string', G0);
set(handles.H0Field, 'string', H0);

% ----- Recuperando ID
% Verifica qual ID foi selecionado no drop_menu
selectedID_index = get(handles.escolhaEventID,'Value');
IDsCell = cellstr(get(handles.escolhaEventID,'String'));
selectedID = str2num( IDsCell{selectedID_index} );

% ------ Calculo dos desvios

flexiVentParameters = getappdata(0, 'flexiVentParameters');

desvios = HTA_desvioParametros (constants, flexiVentParameters);

set(handles.desvioR0, 'string', desvios{1,1} );
set(handles.desvioI0, 'string', desvios{1,2} );
set(handles.desvioG0, 'string', desvios{1,3} );
set(handles.desvioH0, 'string', desvios{1,4} );

% ----- Calculo dos Modelos

CPM0 = HTA_CPMCalculation (R0, I0, G0, H0, f);
CPM = getappdata(0, 'CPM');

% ------ Plotando grafico

HTA_plotarGrafico ( handles, CPM, CPM0, f, realPart, imaginaryPart, freqRetiradas, realPart_retirada, imPart_retirada );
