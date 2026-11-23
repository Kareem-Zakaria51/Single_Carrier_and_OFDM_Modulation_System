function [symbols, nPad] = mapper_16qam(bits)
% MAPPER_16QAM  Gray-mapped 16-QAM (project spec, Figure 2), baseband.
%
%   [symbols, nPad] = mapper_16qam(bits)
%
%   bits    : vector of 0/1, any orientation, any length.
%   symbols : 1 x Nsym complex row vector, Nsym = ceil(numel(bits)/4).
%   nPad    : zero bits appended to reach a multiple of 4.
%
%   Bit order b0 b1 b2 b3 (Figure 2):
%     b0 b1 -> I level,  b2 b3 -> Q level, with the SAME 2-bit Gray rule
%         00 -> -3,  01 -> -1,  11 -> +1,  10 -> +3
%     (figure: I columns left->right 00,01,11,10;
%              Q rows top->bottom 10,11,01,00, i.e. bottom->top 00,01,11,10).
%
%   Normalisation (Eb = 1 as required by Common/awgn_noise.m):
%     unscaled levels {+-1,+-3}: E|I|^2 = (1+9)/2 = 5 per axis, Es = 10.
%     Need Es = k*Eb = 4  ->  scale a = sqrt(4/10) = sqrt(0.4) ~ 0.6325,
%     so the per-axis levels are +-a and +-3a (= +-0.632, +-1.897).
%     (Note: +-1/sqrt(5), +-3/sqrt(5) would give Es = 2, i.e. Eb = 1/2.)
    k = 4;
    bits = bits(:).';
    if any(bits ~= 0 & bits ~= 1)
        error('mapper_16qam:badInput', 'bits must contain only 0 and 1.');
    end
    nPad = mod(-numel(bits), k);
    bits = [bits, zeros(1, nPad)];
    b = double(reshape(bits, k, []));
    lut = [-3, -1, 3, 1];                 % index = 2*bMSB + bLSB + 1
    a   = sqrt(0.4);
    symbols = a * (lut(2*b(1,:) + b(2,:) + 1) + 1j*lut(2*b(3,:) + b(4,:) + 1));
end
