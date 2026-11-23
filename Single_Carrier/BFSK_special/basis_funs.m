
function [phi,t] = basis_funs(nc,Tb,L)

    t = (0:L-1)/L*Tb;

    f1 = (nc+1)/Tb;
    f2 = (nc+2)/Tb;

    phi1 = sqrt(2/Tb)*cos(2*pi*f1*t);
    phi2 = sqrt(2/Tb)*cos(2*pi*f2*t);

    phi = [phi1; phi2];

end
