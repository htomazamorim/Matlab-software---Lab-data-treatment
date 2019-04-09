function [ output_args ] = HTA_coloringBackgrounds( handles, color )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

    set(handles.RField, 'BackgroundColor', color);
    set(handles.IField, 'BackgroundColor', color);
    set(handles.GField, 'BackgroundColor', color);
    set(handles.HField, 'BackgroundColor', color);
    set(handles.CODField, 'BackgroundColor', color);
    
    set(handles.RLogField, 'BackgroundColor', color);
    set(handles.ILogField, 'BackgroundColor', color);
    set(handles.GLogField, 'BackgroundColor', color);
    set(handles.HLogField, 'BackgroundColor', color);
    set(handles.CODLogField, 'BackgroundColor', color);
    
    set(handles.desvioR, 'BackgroundColor', color);
    set(handles.desvioI, 'BackgroundColor', color);
    set(handles.desvioG, 'BackgroundColor', color);
    set(handles.desvioH, 'BackgroundColor', color);
    set(handles.desvioCOD, 'BackgroundColor', color);
    
    set(handles.R0Field, 'BackgroundColor', color);
    set(handles.I0Field, 'BackgroundColor', color);
    set(handles.G0Field, 'BackgroundColor', color);
    set(handles.H0Field, 'BackgroundColor', color);
    set(handles.COD0Field, 'BackgroundColor', color);
    
    set(handles.R0LogField, 'BackgroundColor', color);
    set(handles.I0LogField, 'BackgroundColor', color);
    set(handles.G0LogField, 'BackgroundColor', color);
    set(handles.H0LogField, 'BackgroundColor', color);
    set(handles.COD0LogField, 'BackgroundColor', color);
    
    set(handles.desvioR0, 'BackgroundColor', color);
    set(handles.desvioI0, 'BackgroundColor', color);
    set(handles.desvioG0, 'BackgroundColor', color);
    set(handles.desvioH0, 'BackgroundColor', color);
    set(handles.desvioCOD0, 'BackgroundColor', color);

end

