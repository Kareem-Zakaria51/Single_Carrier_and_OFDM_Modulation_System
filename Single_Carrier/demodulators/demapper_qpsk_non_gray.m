function bits = demapper_qpsk_non_gray(r, nBits)
% DEMAPPER_QPSK_FIG3  Hard-decision (minimum-distance) demapper, Figure 3 QPSK.
%
%   bits = demapper_qpsk_fig3(r)          -> 1 x 2*numel(r) bits
%   bits = demapper_qpsk_fig3(r, nBits)   -> first nBits bits (drops mapper padding)
%
%   Decision regions are still the four quadrants (same points as Figure 2),
%   so slice I and Q by sign and invert the labelling of mapper_qpsk_fig3:
%        sI = (Re r > 0),  sQ = (Im r > 0)
%        b0 = sI,          b1 = sI XOR sQ        (since Q = sign(b0 XOR b1)).
    r = r(:).';
    sI = real(r) > 0;
    sQ = imag(r) > 0;
    bits = zeros(2, numel(r));
    bits(1,:) = sI;
    bits(2,:) = xor(sI, sQ);
    bits = bits(:).';
    if nargin >= 2 && ~isempty(nBits)
        if nBits > numel(bits)
            error('demapper_qpsk_fig3:nBits', 'nBits exceeds the available bits.');
        end
        bits = bits(1:nBits);
    end
end
