%% main_Part1.m  
clear; clc; close all;

%% Paths
root = fileparts(mfilename('fullpath'));
addpath(fullfile(root,'..','Common'));
addpath(fullfile(root,'modulators'));
addpath(fullfile(root,'demodulators'));
addpath(fullfile(root,'BFSK_special'));

%% Simulation parameters
rng(2027,'twister');
Nbits     = 1000008;      
EbN0_dB   = 0:1:12;
minErrors = 200;                     % keep adding blocks until this many errors are counted       
maxBlocks = 20;                      % cap: 20 blocks = ~2e7 bits per Eb/N0 point

resultsDir = fullfile(root,'results');
if ~exist(resultsDir,'dir'), mkdir(resultsDir); end

%% ---------------- Simulations ----------------
BER_bpsk  = run_ber(@mapper_bpsk,           @demapper_bpsk,           EbN0_dB,Nbits,minErrors,maxBlocks);
BER_qpsk2 = run_ber(@mapper_qpsk_gray,      @demapper_qpsk_gray,      EbN0_dB,Nbits,minErrors,maxBlocks);
BER_qpsk3 = run_ber(@mapper_qpsk_non_gray,  @demapper_qpsk_non_gray,  EbN0_dB,Nbits,minErrors,maxBlocks);
BER_8psk  = run_ber(@mapper_8psk,           @demapper_8psk,           EbN0_dB,Nbits,minErrors,maxBlocks);
BER_16qam = run_ber(@mapper_16qam,          @demapper_16qam,          EbN0_dB,Nbits,minErrors,maxBlocks);
BER_bfsk  = run_ber(@mapper_bfsk,           @demapper_bfsk,           EbN0_dB,Nbits,minErrors,maxBlocks);

%% ---------------- Individual figures ----------------
plot_single(EbN0_dB, BER_bpsk,  'bpsk',          'bo-', 'BER of BPSK over AWGN',                 'BER_BPSK',           resultsDir);
plot_single(EbN0_dB, BER_qpsk2, 'qpsk_gray',     'bo-', 'BER of QPSK (Gray mapping, Fig. 2)',    'BER_QPSK_Gray',      resultsDir);
plot_single(EbN0_dB, BER_qpsk3, 'qpsk_non_gray', 'rs-', 'BER of QPSK (Non-Gray mapping, Fig. 3)','BER_QPSK_NonGray',   resultsDir);
plot_single(EbN0_dB, BER_8psk,  '8psk',          'm^-', 'BER of 8PSK over AWGN',                 'BER_8PSK',           resultsDir);
plot_single(EbN0_dB, BER_16qam, '16qam',         'kd-', 'BER of 16QAM over AWGN',                'BER_16QAM',          resultsDir);
plot_single(EbN0_dB, BER_bfsk,  'bfsk',          'gs-', 'BER of Coherent Orthogonal BFSK over AWGN','BER_BFSK',       resultsDir);

%% ---------------- QPSK comparison (Gray vs Non-Gray) ----------------
fig = figure; hold on; grid on;
semilogy(EbN0_dB, BER_qpsk2, 'bo-', 'LineWidth',1.5,'MarkerSize',6);
semilogy(EbN0_dB, BER_qpsk3, 'rs-', 'LineWidth',1.5,'MarkerSize',6);
semilogy(EbN0_dB, theoretical_ber('qpsk_gray',EbN0_dB),     'b--','LineWidth',1.5);
semilogy(EbN0_dB, theoretical_ber('qpsk_non_gray',EbN0_dB), 'r--','LineWidth',1.5);
set(gca,'YScale','log'); ylim([1e-6 1]); xlim([0 12]);
xlabel('E_b/N_0 (dB)'); ylabel('Bit Error Rate (BER)');
title('QPSK Gray vs Non-Gray Encoding');
legend('Gray (sim)','Non-Gray (sim)','Gray (theory)','Non-Gray (theory)','Location','southwest');
save_fig(fig, fullfile(resultsDir,'BER_QPSK_comparison.png'));

%% ---------------- Combined four-scheme figure ----------------
fig = figure; hold on; grid on;
plot_ber(EbN0_dB,BER_bpsk, 'bpsk', 'bo-');
plot_ber(EbN0_dB,BER_qpsk2,'qpsk', 'rs-');
plot_ber(EbN0_dB,BER_8psk, '8psk', 'm^-');
plot_ber(EbN0_dB,BER_16qam,'16qam','kd-');
set(gca,'YScale','log'); ylim([1e-6 1]); xlim([0 12]);
xlabel('E_b/N_0 (dB)'); ylabel('BER');
title('BER of BPSK, QPSK, 8PSK and 16QAM over AWGN');
save_fig(fig, fullfile(resultsDir,'BER_all_schemes.png'));

%% ---------------- Extra: BFSK vs BPSK (shows the 3 dB gap) ----------------
fig = figure; hold on; grid on;
plot_ber(EbN0_dB,BER_bpsk,'bpsk','bo-');
plot_ber(EbN0_dB,BER_bfsk,'bfsk','gs-');
set(gca,'YScale','log'); ylim([1e-6 1]); xlim([0 12]);
xlabel('E_b/N_0 (dB)'); ylabel('BER');
title('BFSK vs BPSK over AWGN');
save_fig(fig, fullfile(resultsDir,'BER_BFSK_vs_BPSK.png'));

%% ---------------- BFSK PSD ----------------
psd_bfsk();

%% ======================= Local functions =======================
function ber = run_ber(mapfun, demapfun, EbN0_dB, Nbits, minErr, maxBlocks)
    ber = zeros(size(EbN0_dB));
    for k = 1:numel(EbN0_dB)
        errs = 0; tot = 0; blk = 0;
        while errs < minErr && blk < maxBlocks
            bits     = generate_bits(Nbits);
            s        = mapfun(bits);
            r        = s + awgn_noise(numel(s),EbN0_dB(k));
            bits_hat = demapfun(r);
            errs = errs + round(calculate_ber(bits,bits_hat)*numel(bits));
            tot  = tot  + numel(bits);
            blk  = blk + 1;
        end
        ber(k) = errs/tot;      
    end
end

function plot_single(EbN0_dB, BER, key, style, ttl, fname, outDir)
    fig = figure; hold on; grid on;
    semilogy(EbN0_dB, BER, style, 'LineWidth',1.5,'MarkerSize',6);
    semilogy(EbN0_dB, theoretical_ber(key,EbN0_dB), 'k--','LineWidth',1.5);
    set(gca,'YScale','log'); ylim([1e-6 1]); xlim([0 12]);
    xlabel('E_b/N_0 (dB)'); ylabel('BER'); title(ttl);
    legend('Simulation','Theory','Location','southwest');
    save_fig(fig, fullfile(outDir,[fname '.png']));
end

function save_fig(fig, path)
    try, theme(fig,'light'); catch, set(fig,'Color','w'); end   % light theme for the report
    drawnow;
    exportgraphics(fig, path, 'Resolution',200);
end
