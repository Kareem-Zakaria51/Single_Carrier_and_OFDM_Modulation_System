function ber = calculate_ber(bits, bits_hat)
    ber = sum(bits(:) ~= bits_hat(:)) / numel(bits);
end