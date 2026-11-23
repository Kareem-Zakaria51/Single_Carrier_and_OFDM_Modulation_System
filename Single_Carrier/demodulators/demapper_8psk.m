function bits_hat = demapper_8psk(rx)
% Minimum-distance decision = nearest of 8 phases
    k2val = [0 1 3 2 6 7 5 4];
    ang = mod(angle(rx), 2*pi);
    k   = mod(round(ang/(pi/4)), 8);
    val = k2val(k + 1);

    b = [bitget(val,3); bitget(val,2); bitget(val,1)];   % MSB first
    bits_hat = reshape(b, 1, []);
end