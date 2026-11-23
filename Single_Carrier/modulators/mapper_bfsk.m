function s = mapper_bfsk(bits)
% bit0 -> 1 (phi1), bit1 -> j (phi2), Eb = 1
    bits = bits(:).';
    s = (1 - bits) + 1j*bits;
end