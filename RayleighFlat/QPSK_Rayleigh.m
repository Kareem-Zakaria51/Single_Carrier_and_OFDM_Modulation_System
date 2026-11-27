%% QPSK_Rayleigh.m  -  Part 2 (QPSK)
% BER of Gray-mapped QPSK (Part 1, Figure 2) over a Rayleigh flat-fading
% channel with perfect channel knowledge and zero-forcing equalisation.
%
%   y = h*x + n      h ~ CN(0,1) (E|h|^2 = 1), one h per symbol (fast fading)
%   x_hat = y ./ h   ->  hard decision with demapper_qpsk_gray
%
% Conventions (same as Part 1): Eb = 1, so QPSK symbols are (+-1 +- 1j),
% Es = 2, and N0 = 1/(Eb/N0). awgn_noise() already uses variance N0/2 per

clear; clc; close all;

%% Paths 
here = fileparts(mfilename('fullpath'));
if isempty(here), here = pwd; end
root = here;                                   % walk up until the folder holding Common/ is found
while ~exist(fullfile(root, 'Common'), 'dir') && ~strcmp(root, fileparts(root))
    root = fileparts(root);
end
if ~exist(fullfile(root, 'Common'), 'dir')
    error('Common/ folder not found. Keep this script inside the project folder.');
end
addpath(fullfile(root, 'Common'));
addpath(fullfile(root, 'Single_Carrier', 'modulators'));
addpath(fullfile(root, 'Single_Carrier', 'demodulators'));
outdir = fullfile(root, 'RayleighFlat', 'results');
if ~exist(outdir, 'dir'), mkdir(outdir); end

%% Settings
EbN0_dB     = 0:2.5:35;        % required range 0 -> 35 dB
blockBits   = 1e6;             % bits per Monte-Carlo block (multiple of 2)
minErrors   = 1000;            % stop a point after this many bit errors ...
maxBits     = 5e7;             % ... or after this many bits
k           = 2;               % bits per QPSK symbol
assert(mod(blockBits, k) == 0, 'Number of bits must be a multiple of 2');

if exist('OCTAVE_VERSION', 'builtin')
    randn('state', 2027); rand('state', 2027); %#ok<RAND>
else
    rng(2027);
end

%% Sanity checks (no noise, no fading)
tst  = generate_bits(1000);
xtst = mapper_qpsk_gray(tst);
assert(calculate_ber(tst, demapper_qpsk_gray(xtst)) == 0, ...
       'Noise-free round trip failed');
fprintf('Mean symbol energy Es = %.4f (expected 2), Eb = %.4f (expected 1)\n', ...
        mean(abs(xtst).^2), mean(abs(xtst).^2) / k);

%% Monte-Carlo simulation
ber_sim = zeros(size(EbN0_dB));
for i = 1:numel(EbN0_dB)
    nErr = 0; nBits = 0;
    while nErr < minErrors && nBits < maxBits
        bits = generate_bits(blockBits);
        x    = mapper_qpsk_gray(bits);
        N    = numel(x);

        h = (randn(1, N) + 1j*randn(1, N)) / sqrt(2);   % Rayleigh, E|h|^2 = 1
        n = awgn_noise(N, EbN0_dB(i));                  % Eb = 1, N0 = 1/(Eb/N0)
        y = h .* x + n;

        x_eq     = y ./ h;                              % zero-forcing equalisation
        bits_hat = demapper_qpsk_gray(x_eq);

        nErr  = nErr  + sum(bits(:) ~= bits_hat(:));
        nBits = nBits + numel(bits);
    end
    ber_sim(i) = nErr / nBits;
    fprintf('Eb/N0 = %5.1f dB | BER = %.3e | bits = %.1e | errors = %d\n', ...
            EbN0_dB(i), ber_sim(i), nBits, nErr);
end

%% Theory
g          = 10.^(EbN0_dB/10);
ber_ray    = 0.5 * (1 - sqrt(g ./ (1 + g)));            % Rayleigh, Gray QPSK
ber_awgn   = theoretical_ber('qpsk', EbN0_dB);          % AWGN reference
ber_awgn(ber_awgn <= 0) = NaN;                          % underflow -> skip on log axis
ber_approx = 1 ./ (4*g);                                % high-SNR: 1/(4 Eb/N0)

%% Plot
fig = figure('Visible', 'off', 'Position', [100 100 800 600]);
semilogy(EbN0_dB, ber_sim,    'bo-', 'LineWidth', 1.4, 'MarkerFaceColor', 'b', ...
         'DisplayName', 'QPSK Rayleigh (simulated)'); hold on;
semilogy(EbN0_dB, ber_ray,    'r--', 'LineWidth', 1.4, ...
         'DisplayName', 'QPSK Rayleigh (theory)');
semilogy(EbN0_dB, ber_approx, 'm:',  'LineWidth', 1.2, ...
         'DisplayName', 'High-SNR approx. 1/(4E_b/N_0)');
semilogy(EbN0_dB, ber_awgn,   'k-.', 'LineWidth', 1.2, ...
         'DisplayName', 'QPSK AWGN (theory)');
grid on; xlabel('E_b/N_0 (dB)'); ylabel('BER');
title('QPSK (Gray) over Rayleigh flat fading, zero-forcing equalisation');
legend('Location', 'southwest');
axis([0 35 1e-6 1]);
imgFile = fullfile(outdir, 'BER_QPSK_Rayleigh.png');
print(fig, imgFile, '-dpng', '-r150');
fprintf('Figure saved to: %s\n', imgFile);
set(fig, 'Visible', 'on');                     % also show it on screen

%% Short report 
fprintf('\n--- Summary ---\n');
fine     = 0:0.01:35;
ray_fine = 0.5 * (1 - sqrt(10.^(fine/10) ./ (1 + 10.^(fine/10))));
awg_fine = theoretical_ber('qpsk', fine);
for tgt = [1e-2 1e-3 1e-4]
    iR = find(ray_fine <= tgt, 1);  iA = find(awg_fine <= tgt, 1);
    if ~isempty(iR) && ~isempty(iA)
        fprintf('BER = %.0e needs Eb/N0 = %.2f dB (Rayleigh) vs %.2f dB (AWGN): penalty %.1f dB\n', ...
                tgt, fine(iR), fine(iA), fine(iR) - fine(iA));
    end
end
fprintf('Max |sim-theory|/theory over all points: %.1f %%\n', ...
        100*max(abs(ber_sim - ber_ray) ./ ber_ray));
