# BPSK over Rayleigh Flat Fading: Results and Comments

**Author:** Fahd
**Script:** `RayleighFlat/BPSK_Rayleigh.m`
**Plot:** `RayleighFlat/results/BER_BPSK_Rayleigh.png`

## Setup

- Channel: y = h x + n, with h = (randn + j randn)/sqrt(2), so E|h|^2 = 1 (Rayleigh amplitude, uniform phase).
- One independent h per symbol. The receiver knows h perfectly.
- Receiver: x_eq = y ./ h (channel compensation), then hard decision with threshold 0.
- Eb = 1, N0 = 1/(Eb/N0). Noise variance N0/2 per dimension.
- Eb/N0 from 0 to 35 dB in 1 dB steps. Each point runs until 1000 bit errors are counted (up to 1.4e7 bits at 35 dB).

## Theory used

| Curve | Formula |
|---|---|
| BPSK over Rayleigh | BER = 0.5 (1 - sqrt( (Eb/N0) / (1 + Eb/N0) )) |
| High-SNR approximation | BER = 1 / (4 Eb/N0) |
| BPSK over AWGN (reference) | Q( sqrt(2 Eb/N0) ) |

## Comments

**Simulation vs theory**
- The simulated curve follows the Rayleigh theory curve over the whole range. The largest difference is 3.4 percent, which is the expected statistical error when each point uses about 1000 errors.

**Shape of the curve**
- Over Rayleigh fading the BER falls only by a factor of 10 for every 10 dB (slope of -1 decade per 10 dB, matching BER = 1/(4 Eb/N0) at high SNR).
- Over AWGN the BER falls extremely fast (it is already below 1e-5 at about 9.6 dB).
- Reason: fading does not only add noise. In deep fades |h| is small, the instantaneous SNR is very low, and the bits sent in those fades are almost always wrong. The average BER is dominated by these rare deep fades, not by the average noise level.

**Power penalty compared with AWGN**

| Target BER | Rayleigh | AWGN | Penalty |
|---|---|---|---|
| 1e-2 | 13.85 dB | 4.33 dB | 9.5 dB |
| 1e-3 | 23.97 dB | 6.79 dB | 17.2 dB |
| 1e-4 | 33.98 dB | 8.40 dB | 25.6 dB |

- The lower the target BER, the larger the penalty. A BER of 1e-4 over Rayleigh needs about 34 dB, which is why the required SNR range is 0 to 35 dB.

**Equalisation**
- Dividing by h removes the channel's phase and gain, so a simple threshold at 0 is enough. The cost is that when |h| is small the division amplifies the noise by 1/|h|, which is exactly what produces the errors in deep fades.

**Conclusion**
- Plain BPSK over a flat Rayleigh channel is very inefficient in power. Practical systems need diversity, coding or interleaving to avoid paying this penalty. This motivates the repetition code and interleaver used in the OFDM part (Part 3).

## Files delivered

- `RayleighFlat/BPSK_Rayleigh.m`
- `RayleighFlat/results/BER_BPSK_Rayleigh.png`
- `RayleighFlat/results/Fahd_BPSK_Rayleigh_comments.md`
