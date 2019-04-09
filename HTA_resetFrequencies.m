function [ output_args ] = HTA_resetFrequencies( handles )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

f = { handles.f1, handles.f2, handles.f3, handles.f4, ...
handles.f5, handles.f6, handles.f7, handles.f8, ...
handles.f9, handles.f10, handles.f11, handles.f12, handles.f13 };

for i=1:13
    set(f{1, i}, 'value', 1);
end

end

