function symbols = mapper_BPSK(bits)
% BPSK mapper (Eb = 1): bit 0 -> -1, bit 1 -> +1
    symbols = 2*bits - 1;
end