function [symbols, nPad] = mapper_qpsk_fig2(bits)
% MAPPER_QPSK_FIG2  Gray-mapped QPSK (project spec, Figure 2), baseband.
%
%   [symbols, nPad] = mapper_qpsk_fig2(bits)
%
%   bits    : vector of 0/1, any orientation, any length.
%   symbols : 1 x Nsym complex row vector, Nsym = ceil(numel(bits)/2).
%   nPad    : number of zero bits appended so the length is a multiple of 2.
%             Pass the original bit count to the demapper to drop them again.
%
%   Constellation (b0 b1), from Figure 2:
%        01 (-1,+1)   |   11 (+1,+1)
%        -------------+-------------
%        00 (-1,-1)   |   10 (+1,-1)
%   b0 selects the sign of I, b1 the sign of Q  ->  Gray mapping.
%
%   Normalisation: |s|^2 = 2 for every point, so Es = 2 and
%   Eb = Es/2 = 1, which is what Common/awgn_noise.m assumes.
    k = 2;
    bits = bits(:).';
    if any(bits ~= 0 & bits ~= 1)
        error('mapper_qpsk_fig2:badInput', 'bits must contain only 0 and 1.');
    end
    nPad = mod(-numel(bits), k);
    bits = [bits, zeros(1, nPad)];
    b = double(reshape(bits, k, []));
    symbols = (2*b(1,:) - 1) + 1j*(2*b(2,:) - 1);
end
