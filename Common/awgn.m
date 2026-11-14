function n = awgn_noise(len, EbN0_dB)
% Complex AWGN for Eb = 1. Variance N0/2 per dimension.
    N0 = 1 / 10^(EbN0_dB/10);
    n  = sqrt(N0/2) * (randn(1,len) + 1j*randn(1,len));
end