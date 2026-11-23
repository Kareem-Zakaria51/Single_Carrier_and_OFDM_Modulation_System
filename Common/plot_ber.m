function plot_ber(EbN0_dB, ber_sim, scheme, style)
% Adds the simulated curve and the theoretical curve to the current figure.
    if nargin < 4, style = 'o-'; end
    semilogy(EbN0_dB, ber_sim, style, 'LineWidth', 1.3, ...
             'DisplayName', [upper(scheme) ' (sim)']); hold on;
    semilogy(EbN0_dB, theoretical_ber(scheme, EbN0_dB), '--', ...
             'LineWidth', 1.2, 'DisplayName', [upper(scheme) ' (theory)']);
    grid on; xlabel('E_b/N_0 (dB)'); ylabel('BER'); ylim([1e-5 1]);
    legend('Location','southwest');
end