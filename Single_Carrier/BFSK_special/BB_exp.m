
function [sBB,t,fc] = BB_exp(Eb,Tb,nc,L)

    fc = nc/Tb;

    t = (0:L-1)/L*Tb;

    s1 = sqrt(2*Eb/Tb)*exp(1j*2*pi*t/Tb);
    s2 = sqrt(2*Eb/Tb)*exp(1j*4*pi*t/Tb);

    sBB = [s1; s2];

end
