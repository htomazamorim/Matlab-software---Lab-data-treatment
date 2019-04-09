for i=1:1    
    R=[0.324618, 0.281293, 0.290188, 0.526421, 0.449617];
    I=[-0.000166799, -0.00007252, -0.00010034, -0.000329848, -0.000383286];
    G=[3.31864, 2.96948, 2.84945, 4.56401, 3.83502];
    H=[14.1, 15.5195, 14.9297, 19.2299, 15.2882];
    phi=[0.00095226, 0.0012171, 0.0026556, 0.0039136, 0.0038613];
    F=[8.64, 5.78];
    p=[3,4];
    
    Hes = HTA_elip( R(i), I(i), G(i), H(i) );
    % Matrizes possiveis dois a dois
    RG = [Hes(1,1), Hes(1,3); Hes(3,1), Hes(3,3)];
    RH = [Hes(1,1), Hes(1,4); Hes(4,1), Hes(4,4)];
    GH = [Hes(3,3), Hes(3,4); Hes(4,3), Hes(4,4)];
    M = [Hes(1,1), Hes(1,3), Hes(1,4); Hes(3,1), Hes(3,3), Hes(3,4); Hes(4,1), Hes(4,3), Hes(4,4)];


    [V1, D1] = eig(RG);
    [V2, D2] = eig(RH);
    [V3, D3] = eig(GH);

    [Vh, Dh] = eig(Hes);
    [Vm, Dm] = eig(M);


    %19.45
    errPhi = 2*p(1)*(phi(i)*13/(26-p(1)))/(F(1));
    errPhiM = 2*p(1)*(phi(i)*13/(26-p(1)))/(F(1));
    errPhiH = 2*p(2)*(phi(i)*13/(26-p(2)))/(F(2));

    theta1 = (V1(2,1)/abs(V1(2,1)))*acos(V1(1,1)/(V1(1,1)^2+V1(2,1)^2)^0.5);
    eig1_1 = D1(1,1);
    eig2_1 = D1(2,2);
    
    theta2 = (V2(2,1)/abs(V2(2,1)))*acos(V2(1,1)/(V2(1,1)^2+V2(2,1)^2)^0.5);
    eig1_2 = D2(1,1);
    eig2_2 = D2(2,2);
    
    theta3 = (V3(2,1)/abs(V3(2,1)))*acos(V3(1,1)/(V3(1,1)^2+V3(2,1)^2)^0.5);
    eig1_3 = D3(1,1);
    eig2_3 = D3(2,2);
    
    for i=1:630
        j=(i-10)/100;
        x_1(i) = sqrt(errPhi)*(cos(theta1)*cos(j)/sqrt(eig1_1)-sin(theta1)*sin(j)/sqrt(eig2_1));
        y_1(i) = sqrt(errPhi)*(sin(theta1)*cos(j)/sqrt(eig1_1)+cos(theta1)*sin(j)/sqrt(eig2_1));
        
        x_2(i) = sqrt(errPhi)*(cos(theta2)*cos(j)/sqrt(eig1_2)-sin(theta2)*sin(j)/sqrt(eig2_2));
        y_2(i) = sqrt(errPhi)*(sin(theta2)*cos(j)/sqrt(eig1_2)+cos(theta2)*sin(j)/sqrt(eig2_2));
        
        x_3(i) = sqrt(errPhi)*(cos(theta3)*cos(j)/sqrt(eig1_3)-sin(theta3)*sin(j)/sqrt(eig2_3));
        y_3(i) = sqrt(errPhi)*(sin(theta3)*cos(j)/sqrt(eig1_3)+cos(theta3)*sin(j)/sqrt(eig2_3));
    end
    
    
    detM = Dm(1,1)*Dm(2,2)*Dm(3,3);
    detH = Dh(1,1)*Dh(2,2)*Dh(3,3)*Dh(4,4);

    vol = 4*pi*sqrt(errPhiM^3)/(3*sqrt(detM))
    vol = 4*pi*sqrt(errPhiH^3)/(3*sqrt(detH))
    
    plot(x_1, y_1, x_2, y_2, x_3, y_3);
end

