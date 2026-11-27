%% 16QAM_Rayleigh.m  -  Part 2 (16-QAM)
% BER of Gray-mapped 16-QAM (Part 1, Figure 2) over a Rayleigh flat-fading
% channel with perfect channel knowledge and zero-forcing equalisation.
%
%   y = h*x + n      h ~ CN(0,1) (E|h|^2 = 1), one h per symbol (fast fading)
%   x_hat = y ./ h   ->  hard decision with demapper_16qam
%
% Conventions (same as Part 1): Eb = 1, so Es = 4 (mapper levels
% +-0.632, +-1.897), N0 = 1/(Eb/N0). awgn_noise() uses variance N0/2 per

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
EbN0_dB   = 0:2.5:40;          % required range 0 -> 40 dB
blockBits = 1e6;               % bits per Monte-Carlo block (multiple of 4)
minErrors = 1000;              % stop a point after this many bit errors ...
maxBits   = 5e7;               % ... or after this many bits
k         = 4;                 % bits per 16-QAM symbol
assert(mod(blockBits, k) == 0, 'Number of bits must be a multiple of 4');

if exist('OCTAVE_VERSION', 'builtin')
    randn('state', 2027); rand('state', 2027); %#ok<RAND>
else
    rng(2027);
end

%% Sanity checks (no noise, no fading)
tst  = generate_bits(4000);
xtst = mapper_16qam(tst);
assert(calculate_ber(tst, demapper_16qam(xtst)) == 0, 'Noise-free round trip failed');
fprintf('Mean symbol energy Es = %.4f (expected 4), Eb = %.4f (expected 1)\n', ...
        mean(abs(xtst).^2), mean(abs(xtst).^2) / k);

%% Monte-Carlo simulation
ber_sim = zeros(size(EbN0_dB));
for i = 1:numel(EbN0_dB)
    nErr = 0; nBits = 0;
    while nErr < minErrors && nBits < maxBits
        bits = generate_bits(blockBits);
        x    = mapper_16qam(bits);
        N    = numel(x);

        h = (randn(1, N) + 1j*randn(1, N)) / sqrt(2);   % Rayleigh, E|h|^2 = 1
        n = awgn_noise(N, EbN0_dB(i));                  % Eb = 1, N0 = 1/(Eb/N0)
        y = h .* x + n;

        x_eq     = y ./ h;                              % zero-forcing equalisation
        bits_hat = demapper_16qam(x_eq);

        nErr  = nErr  + sum(bits(:) ~= bits_hat(:));
        nBits = nBits + numel(bits);
    end
    ber_sim(i) = nErr / nBits;
    fprintf('Eb/N0 = %5.1f dB | BER = %.3e | bits = %.1e | errors = %d\n', ...
            EbN0_dB(i), ber_sim(i), nBits, nErr);
end

%% Theory
% Exact Gray 16-QAM over AWGN (per-axis 4-PAM, a^2 = 0.4 Eb):
%   Pb = 3/4 Q(a/s) + 1/2 Q(3a/s) - 1/4 Q(5a/s),  (a/s)^2 = 0.8 Eb/N0
% Averaging Q(sqrt(2 m g)) over |h|^2 ~ Exp(1) gives 0.5*(1 - sqrt(m g/(1+m g))),
% with m = 0.4, 3.6, 10 for the three terms.
rq      = @(m, g) 0.5 * (1 - sqrt(m*g ./ (1 + m*g)));
ray16   = @(g) 0.75*rq(0.4, g) + 0.5*rq(3.6, g) - 0.25*rq(10, g);
g          = 10.^(EbN0_dB/10);
ber_ray    = ray16(g);                                  % Rayleigh, Gray 16-QAM
ber_awgn   = theoretical_ber('16qam', EbN0_dB);         % AWGN reference
ber_awgn(ber_awgn <= 0) = NaN;
ber_approx = (0.75/0.4 + 0.5/3.6 - 0.25/10) ./ (4*g);   % high-SNR approx ~ 0.5/(Eb/N0)

%% Plot
fig = figure('Visible', 'off', 'Position', [100 100 800 600]);
semilogy(EbN0_dB, ber_sim,    'bo-', 'LineWidth', 1.4, 'MarkerFaceColor', 'b', ...
         'DisplayName', '16-QAM Rayleigh (simulated)'); hold on;
semilogy(EbN0_dB, ber_ray,    'r--', 'LineWidth', 1.4, ...
         'DisplayName', '16-QAM Rayleigh (theory)');
semilogy(EbN0_dB, ber_approx, 'm:',  'LineWidth', 1.2, ...
         'DisplayName', 'High-SNR approx. \approx 0.5/(E_b/N_0)');
semilogy(EbN0_dB, ber_awgn,   'k-.', 'LineWidth', 1.2, ...
         'DisplayName', '16-QAM AWGN (theory)');
grid on; xlabel('E_b/N_0 (dB)'); ylabel('BER');
title('16-QAM (Gray) over Rayleigh flat fading, zero-forcing equalisation');
legend('Location', 'southwest');
axis([0 40 1e-6 1]);
imgFile = fullfile(outdir, 'BER_16QAM_Rayleigh.png');
print(fig, imgFile, '-dpng', '-r150');
fprintf('Figure saved to: %s\n', imgFile);
set(fig, 'Visible', 'on');                     % also show it on screen

%% Short report
fprintf('\n--- Summary ---\n');
fine     = 0:0.01:40;
ray_fine = ray16(10.^(fine/10));
awg_fine = theoretical_ber('16qam', fine);
for tgt = [1e-2 1e-3 1e-4]
    iR = find(ray_fine <= tgt, 1);  iA = find(awg_fine <= tgt, 1);
    if ~isempty(iR) && ~isempty(iA)
        fprintf('BER = %.0e needs Eb/N0 = %.2f dB (Rayleigh) vs %.2f dB (AWGN): penalty %.1f dB\n', ...
                tgt, fine(iR), fine(iA), fine(iR) - fine(iA));
    end
end
fprintf('Max |sim-theory|/theory over all points: %.1f %%\n', ...
        100*max(abs(ber_sim - ber_ray) ./ ber_ray));
