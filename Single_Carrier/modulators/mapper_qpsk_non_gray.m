function [symbols, nPad] = mapper_qpsk_fig3(bits)
% MAPPER_QPSK_FIG3  Non-Gray QPSK (project spec, Figure 3), baseband.
%
%   [symbols, nPad] = mapper_qpsk_fig3(bits)
%
%   Same interface and normalisation (Es = 2, Eb = 1) as mapper_qpsk_fig2.
%
%   Constellation (b0 b1), from Figure 3:
%        01 (-1,+1)   |   10 (+1,+1)
%        -------------+-------------
%        00 (-1,-1)   |   11 (+1,-1)
%   Vertical neighbours (01-00, 10-11) differ in ONE bit, but horizontal
%   neighbours (01-10, 00-11) differ in TWO bits -> not a Gray mapping.
%
%   Closed form:  I = sign(b0),   Q = sign(b0 XOR b1)
%   (check: 01 -> I-, Q+ ; 10 -> I+, Q+ ; 00 -> I-, Q- ; 11 -> I+, Q-).
    k = 2;
    bits = bits(:).';
    if any(bits ~= 0 & bits ~= 1)
        error('mapper_qpsk_fig3:badInput', 'bits must contain only 0 and 1.');
    end
    nPad = mod(-numel(bits), k);
    bits = [bits, zeros(1, nPad)];
    b = double(reshape(bits, k, []));
    qbit = double(xor(b(1,:) > 0, b(2,:) > 0));
    symbols = (2*b(1,:) - 1) + 1j*(2*qbit - 1);
end
