function [ H ] = HTA_elip( R, I, G, H )
%UNTITLED2 Summary of this function goes here
%   Calcula matriz hessiana
f = [1.0, 1.5, 2.5, 3.5, 5.5, 6.5, 8.5, 9.5, 11.5, 14.5, 15.5, 18.5, 20.5];
w=2*pi*f;

alpha = (2/pi)*atan(H/G);
denominador = ((H^2+G^2)*(w.^2));

modZ = (R+G./w.^alpha).^2+(w*I-H./w.^alpha).^2;

    h11=1;
    h12 = 0;
    h13 = ((2/pi)*G*H*log(w)+G^2+H^2)./denominador;
    h14 = -((2/pi)*G^2*log(w))./denominador;

    h22 = w.^2;
    h23 = -((2/pi)*H^2.*log(w).*w)./denominador;
    h24 = -((H^2+G^2-(2/pi)*H*G*log(w)).*w)./denominador;

    h33 = h13.^2 + (h23./w).^2;
    h34 = h14.*h13 + (h23./w).*(h24./w);

    h44 = h14.^2+ (h24./w).^2;

H11=0;
H12=0;
H13=0;
H14=0;
H22=0;
H23=0;
H24=0;
H33=0;
H34=0;
H44=0;
    
    
for i=1:13
    H11 = H11 + h11 / modZ(i);
    H12 = H12 + h12 / modZ(i);
    H13 = H13 + h13(i) / modZ(i);
    H14 = H14 + h14(i) / modZ(i);
    
    H22 = H22 + h22(i) / modZ(i);
    H23 = H23 + h23(i) / modZ(i);
    H24 = H24 + h24(i) / modZ(i);
    
    H33 = H33 + h33(i) / modZ(i);
    H34 = H34 + h34(i) / modZ(i);
    
    H44 = H44 + h44(i) / modZ(i);
end

H = [H11, H12, H13, H14; H12, H22, H23, H24; H13, H23, H33, H34; H14, H24, H34, H44];


end

