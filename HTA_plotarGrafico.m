function [ output_args ] = HTA_plotarGrafico( handles, CPM, CPM0, f, realPart, imaginaryPart, freqRetiradas, realPart_retirada, imPart_retirada )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

if ( and ( isequal (CPM{1,1}, CPM0{1,1}), isequal (CPM{1,2}, CPM0{1,2}) ) )
    axes(handles.axes1);
    cla reset;
    
    plot(handles.axes1,f, CPM{1,1}, 'k', f, CPM{1,2}, 'r', f, realPart,'ko',f,imaginaryPart,'kX', 'lineWidth', 2);    
    set(handles.axes1,'xgrid','on','ygrid','on');
    title('Ajuste do modelo de fase constante à impedância respiratória');
    legend('Z modelo Real ','Z modelo Imaginário ', 'Z calculado Real ','Z calculado Imaginário ','Location', 'southeast');
   
    set(handles.fTable, 'data', HTA_buildFreqTable(realPart, imaginaryPart, CPM{1,1}, CPM{1,2}));
else
    axes(handles.axes1);
    cla reset;
    
    plot(handles.axes1,freqRetiradas, realPart_retirada, 'or', freqRetiradas, imPart_retirada, 'or', 'lineWidth', 2);
    hold on;
    
    plot(handles.axes1,f, CPM{1,1}, 'k', f, CPM{1,2}, 'r', f, CPM0{1,1}, '--', f, CPM0{1,2}, '--', f,realPart,'kx',f,imaginaryPart,'k+', 'lineWidth', 2);    
    set(handles.axes1,'xgrid','on','ygrid','on');
    title('Ajuste do modelo de fase constante à impedância respiratória');
    legend('Frequência retirada ','Frequência retirada ','Z modelo Real ','Z modelo Imaginário ', 'Z modelo Real Reajustado','Z modelo Imaginário Reajustado', 'flexiVent Real ','flexiVent Imaginário ','Location', 'southeast');
    
    set(handles.fTable, 'data', HTA_buildFreqTable(realPart, imaginaryPart, CPM0{1,1}, CPM0{1,2}));
end

end

