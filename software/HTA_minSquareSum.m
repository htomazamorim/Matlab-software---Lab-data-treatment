function S = HTA_minSquareSum( impedanceModelConstants, frequencies, realPart, imaginaryPart )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% impedanceModelConstants = [R, I, G, H]


% Define-se a frequencia angular
w = (2*pi).*frequencies;

% Define-se alpha
alpha = (2/pi)*atan(impedanceModelConstants(4)/impedanceModelConstants(3));

% a = modelRealPart = R + (G/w^alpha)
modelRealPart = impedanceModelConstants(1) + impedanceModelConstants(3)./(w).^alpha;

% b = modelImaginaryPart = I*w - (H/w^alpha)
modelImaginaryPart = (impedanceModelConstants(2)*w - impedanceModelConstants(4)./(w).^alpha);

% modelComplexNumber = a + bi
modelComplexNumber = complex(modelRealPart, modelImaginaryPart);

% dataComplexNumber = realPart + imaginaryPart*i
dataComplexNumber = complex(realPart, imaginaryPart);

% Defini-se a subtração do (cálculo pelo modelo) pelas (medidas reais tomadas), ao quadrado (variável S)
F = ( abs(modelComplexNumber - dataComplexNumber) ).^2;

S=sqrt(sum(F)/length(w));

end

