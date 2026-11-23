function bits = demapper_qpsk_gray(r, nBits)
% DEMAPPER_QPSK_FIG2  Hard-decision (minimum-distance) demapper, Figure 2 QPSK.
%
%   bits = demapper_qpsk_fig2(r)          -> 1 x 2*numel(r) bits
%   bits = demapper_qpsk_fig2(r, nBits)   -> first nBits bits (drops mapper padding)
%
%   For this constellation the minimum-distance decision regions are the four
%   quadrants, so the decision is a sign test on I and Q (vectorised, no loops):
%        b0 = (Re r > 0),   b1 = (Im r > 0).
%   (A tie, exactly 0, is decided as bit 0.)
    r = r(:).';
    bits = zeros(2, numel(r));
    bits(1,:) = real(r) > 0;
    bits(2,:) = imag(r) > 0;
    bits = bits(:).';
    if nargin >= 2 && ~isempty(nBits)
        if nBits > numel(bits)
            error('demapper_qpsk_fig2:nBits', 'nBits exceeds the available bits.');
        end
        bits = bits(1:nBits);
    end
end
