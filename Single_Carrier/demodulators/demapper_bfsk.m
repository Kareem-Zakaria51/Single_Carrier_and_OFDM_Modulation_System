function bits_hat = demapper_bfsk(r)
% r : received complex samples (r1 + j*r2)
% decide bit 1 if the phi2 correlator output is larger than phi1
    bits_hat = double(imag(r(:).') > real(r(:).'));
end