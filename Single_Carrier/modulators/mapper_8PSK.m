function symbols = mapper_8PSK(bits)
% 8PSK Gray mapper (Figure 2), radius sqrt(3) so Eb = 1 (Es = 3).
% bits length must be a multiple of 3.
    k2val = [0 1 3 2 6 7 5 4];        % k (angle index) -> decimal value of bits
    val2k = zeros(1,8);
    val2k(k2val + 1) = 0:7;           % decimal value -> k

    b   = reshape(bits, 3, []);
    val = 4*b(1,:) + 2*b(2,:) + b(3,:);
    k   = val2k(val + 1);
    symbols = sqrt(3) * exp(1j*pi*k/4);
end