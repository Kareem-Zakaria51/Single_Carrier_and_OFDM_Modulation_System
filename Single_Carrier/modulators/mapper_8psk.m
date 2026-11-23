function symbols = mapper_8psk(bits)

    % Convert input to a row vector
    bits = double(bits(:).');

    % Validate binary input
    if any(bits ~= 0 & bits ~= 1)
        error('Input must contain binary bits.');
    end

    % Check that bit count is divisible by 3
    if mod(numel(bits),3) ~= 0
        error('8PSK requires a multiple of 3 bits.');
    end

    % Gray mapping: angle index -> decimal bit value
    k2val = [0 1 3 2 6 7 5 4];

    % Reverse mapping: decimal bit value -> angle index
    val2k = zeros(1,8);
    val2k(k2val + 1) = 0:7;

    % Group every 3 bits
    b = reshape(bits,3,[]);

    % Convert binary groups to decimal
    val = 4*b(1,:) + 2*b(2,:) + b(3,:);

    % Find corresponding constellation index
    k = val2k(val + 1);

    % Generate 8PSK symbols (Eb = 1)
    symbols = sqrt(3) * exp(1j*pi*k/4);

end