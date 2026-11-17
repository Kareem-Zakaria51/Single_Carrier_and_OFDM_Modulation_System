clear; clc; close all;
addpath('../Common', 'modulators', 'demodulators');

EbN0_dB = 0:1:12;
N = 3e6;                      % multiple of 3 (needed for 8PSK)

ber_bpsk = zeros(size(EbN0_dB));
ber_8psk = zeros(size(EbN0_dB));

for i = 1:length(EbN0_dB)
    % ---- BPSK ----
    bits = generate_bits(N);
    tx   = mapper_BPSK(bits);
    rx   = tx + awgn_noise(length(tx), EbN0_dB(i));
    ber_bpsk(i) = calculate_ber(bits, demapper_BPSK(rx));

    % ---- 8PSK ----
    bits = generate_bits(N);
    tx   = mapper_8PSK(bits);
    rx   = tx + awgn_noise(length(tx), EbN0_dB(i));
    ber_8psk(i) = calculate_ber(bits, demapper_8PSK(rx));
end

figure; plot_ber(EbN0_dB, ber_bpsk, 'bpsk', 'o-');
        plot_ber(EbN0_dB, ber_8psk, '8psk', 's-');
title('BER vs E_b/N_0: BPSK and 8PSK (AWGN)');
saveas(gcf, 'results/BER_BPSK_8PSK.png');