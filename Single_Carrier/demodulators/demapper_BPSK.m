function bits_hat = demapper_BPSK(rx)
% Hard decision, threshold = 0 on the real part
    bits_hat = double(real(rx) > 0);
end