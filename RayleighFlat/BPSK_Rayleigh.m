%% BPSK_Rayleigh.m  -  Part 2 (Fahd)
% BER of BPSK over a Rayleigh flat-fading channel, channel known at the
% receiver (perfect CSI), equalisation by division, hard decision.
%
%   y = h*x + n        h = (randn + 1j*randn)/sqrt(2)   ->  E|h|^2 = 1
%   x_eq = y ./ h      ->  bits_hat = demapper_bpsk(x_eq)
%
% Conventions (same as Part 1): Eb = 1, BPSK symbols are +-1,
% N0 = 1/(Eb/N0). awgn_noise() uses variance N0/2 per dimension.

clear; clc; close all;

%% Paths
here = fileparts(mfilename('fullpath'));
root = fileparts(here);
addpath(fullfile(root, 'Common'));
addpath(fullfile(root, 'Single_Carrier', 'modulators'));
addpath(fullfile(root, 'Single_Carrier', 'demodulators'));
outdir = fullfile(here, 'results');
if ~exist(outdir, 'dir'), mkdir(outdir); end

%% Settings
EbN0_dB   = 0:1:35;        % required range 0 -> 35 dB
blockBits = 1e6;           % bits per Monte-Carlo block
minErrors = 1000;          % stop a point after this many bit errors ...
maxBits   = 5e7;           % ... or after this many bits

if exist('OCTAVE_VERSION', 'builtin')
    randn('state', 2027); rand('state', 2027); %#ok<RAND>
else
    rng(2027);
end

%% Sanity check (no noise, no fading)
tst = generate_bits(1000);
assert(calculate_ber(tst, demapper_bpsk(mapper_bpsk(tst))) == 0, ...
       'Noise-free round trip failed');

%% Monte-Carlo simulation
ber_sim = zeros(size(EbN0_dB));
for i = 1:numel(EbN0_dB)
    nErr = 0; nBits = 0;
    while nErr < minErrors && nBits < maxBits
        bits = generate_bits(blockBits);
        x    = mapper_bpsk(bits);
        N    = numel(x);

        h = (randn(1, N) + 1j*randn(1, N)) / sqrt(2);   % Rayleigh, E|h|^2 = 1
        n = awgn_noise(N, EbN0_dB(i));                  % Eb = 1
        y = h .* x + n;

        x_eq     = y ./ h;                              % channel compensation
        bits_hat = demapper_bpsk(x_eq);                 % threshold = 0

        nErr  = nErr  + sum(bits(:) ~= bits_hat(:));
        nBits = nBits + numel(bits);
    end
    ber_sim(i) = nErr / nBits;
    fprintf('Eb/N0 = %5.1f dB | BER = %.3e | bits = %.1e | errors = %d\n', ...
            EbN0_dB(i), ber_sim(i), nBits, nErr);
end

%% Theory
g          = 10.^(EbN0_dB/10);
ber_ray    = 0.5 * (1 - sqrt(g ./ (1 + g)));      % BPSK over Rayleigh
ber_approx = 1 ./ (4*g);                          % high-SNR: 1/(4 Eb/N0)
ber_awgn   = theoretical_ber('bpsk', EbN0_dB);    % AWGN reference
ber_awgn(ber_awgn <= 0) = NaN;                    % skip underflow on log axis

%% Plot
fig = figure('Position', [100 100 800 600]);
semilogy(EbN0_dB, ber_sim,    'bo-', 'LineWidth', 1.4, 'MarkerFaceColor', 'b', ...
         'DisplayName', 'BPSK Rayleigh (simulated)'); hold on;
semilogy(EbN0_dB, ber_ray,    'r--', 'LineWidth', 1.4, ...
         'DisplayName', 'BPSK Rayleigh (theory)');
semilogy(EbN0_dB, ber_approx, 'm:',  'LineWidth', 1.2, ...
         'DisplayName', 'High-SNR approx. 1/(4E_b/N_0)');
semilogy(EbN0_dB, ber_awgn,   'k-.', 'LineWidth', 1.2, ...
         'DisplayName', 'BPSK AWGN (theory)');
grid on; xlabel('E_b/N_0 (dB)'); ylabel('BER');
title('BPSK over Rayleigh flat fading, perfect CSI');
legend('Location', 'southwest');
axis([0 35 1e-6 1]);
print(fig, fullfile(outdir, 'BER_BPSK_Rayleigh.png'), '-dpng', '-r150');

%% Summary
fprintf('\n--- Summary ---\n');
fine     = 0:0.01:50;
gf       = 10.^(fine/10);
ray_fine = 0.5 * (1 - sqrt(gf ./ (1 + gf)));
awg_fine = theoretical_ber('bpsk', fine);
for tgt = [1e-2 1e-3 1e-4]
    iR = find(ray_fine <= tgt, 1);  iA = find(awg_fine <= tgt, 1);
    if ~isempty(iR) && ~isempty(iA)
        fprintf('BER = %.0e needs Eb/N0 = %.2f dB (Rayleigh) vs %.2f dB (AWGN): penalty %.1f dB\n', ...
                tgt, fine(iR), fine(iA), fine(iR) - fine(iA));
    end
end
fprintf('Max |sim-theory|/theory over all points: %.1f %%\n', ...
        100*max(abs(ber_sim - ber_ray) ./ ber_ray));