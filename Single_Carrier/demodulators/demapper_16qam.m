function bits = demapper_16qam(r, nBits)
% DEMAPPER_16QAM  Hard-decision (minimum-distance) demapper for 16-QAM.
%
%   bits = demapper_16qam(r)          -> 1 x 4*numel(r) bits (b0 b1 b2 b3 per symbol)
%   bits = demapper_16qam(r, nBits)   -> first nBits bits (drops mapper padding)
%
%   The constellation is a product of two 4-PAM axes, so the minimum-distance
%   decision is separable: slice each axis at 0 and +-2 (in units of a, where
%   a = sqrt(0.4) is the spacing/2 set in mapper_16qam). With x = Re(r)/a:
%        level  -3   -1   +1   +3        <-> bits  00  01  11  10
%        region x<-2  -2..0  0..2  x>2
%        first bit  = (x > 0)            (sign)
%        second bit = (|x| < 2)          (inner level)
%   The same rule is applied to y = Im(r)/a for b2 b3. Fully vectorised.
    a = sqrt(0.4);
    r = r(:).';
    x = real(r) / a;
    y = imag(r) / a;
    bits = zeros(4, numel(r));
    bits(1,:) = x > 0;
    bits(2,:) = abs(x) < 2;
    bits(3,:) = y > 0;
    bits(4,:) = abs(y) < 2;
    bits = bits(:).';
    if nargin >= 2 && ~isempty(nBits)
        if nBits > numel(bits)
            error('demapper_16qam:nBits', 'nBits exceeds the available bits.');
        end
        bits = bits(1:nBits);
    end
end
