# Part 2 - QPSK (Gray, Figure 2) over Rayleigh flat fading - Kareem Ash

**Setup:** y = h·x + n, h = (randn + j·randn)/√2 (E|h|² = 1, one independent h per symbol), Eb = 1 (QPSK symbols ±1±j, Es = 2), zero-forcing equalisation `y ./ h`, then the Part 1 Gray demapper. Eb/N0 = 0 → 35 dB in 2.5 dB steps; every point simulated until ≥ 1000 bit errors (up to 5·10⁷ bits). Fixed seed.

**Results**
- The simulated curve follows the theoretical Rayleigh BER, `0.5·(1 − √(γ/(1+γ)))` with γ = Eb/N0, within Monte-Carlo scatter (≤ ~5 % relative, i.e. ~1000-error statistics) over the whole range. The same formula applies to BPSK, so QPSK and BPSK have identical BER vs Eb/N0 under fading, as they do under AWGN.
- Fading destroys the waterfall shape: the curve is almost a straight line of slope −1 decade per 10 dB, matching the high-SNR approximation BER ≈ 1/(4·Eb/N0). That is diversity order 1: errors are dominated by deep fades (small |h|), not by the noise level.
- Cost versus AWGN at the same BER: BER = 1e-2 needs 13.9 dB (AWGN 4.3 dB, penalty ≈ 9.5 dB), 1e-3 needs 24.0 dB (AWGN 6.8 dB, ≈ 17.2 dB), 1e-4 needs 34.0 dB (AWGN 8.4 dB, ≈ 25.6 dB). The penalty keeps growing as the target BER falls, which is why the 0 → 35 dB range is needed.
- Zero-forcing equalisation is optimal here for hard-decision QPSK: y/h differs from the coherent matched-filter output only by a positive scale factor, so the decisions are the same. Its weakness (noise enhancement n/h in deep fades) is what produces the 1/SNR behaviour above; the cure would be diversity or coding, not a different equaliser.
- Gray mapping still matters: neighbouring symbols differ by one bit, so BER ≈ SER/2 per dimension.
