# BPSK and 8PSK: Results and Comments

**Author:** Fahd
**Channel:** AWGN, baseband equivalent system, Eb = 1
**Plot:** `Single_Carrier/results/BER_BPSK_8PSK.png`
**Simulation:** 3,000,000 bits per Eb/N0 point, Eb/N0 from 0 to 12 dB

## Theoretical BER used

| Scheme | Theoretical BER |
|---|---|
| BPSK | Q(sqrt(2 Eb/N0)) |
| 8PSK (Gray) | (2/3) Q( sqrt(6 Eb/N0) sin(pi/8) ) |

## Comments

**BPSK**
- The simulated curve matches the theoretical curve almost exactly over the whole range.
- BPSK reaches a BER of 10^-3 at about 6.8 dB and 10^-5 at about 9.6 dB.
- Its two symbols (+1 and -1) are as far apart as possible for a given Eb, so it is the most power-efficient scheme in this project.
- The curve stops near 9.5 dB because no errors were counted there. A log axis cannot show a BER of zero, so a larger number of bits would be needed to go lower.

**8PSK**
- The simulated curve follows the theoretical approximation closely.
- 8PSK reaches a BER of 10^-3 at about 10 dB.
- It sends 3 bits per symbol, but its 8 points are packed on a circle, so the minimum distance between neighbours is smaller (proportional to sin(pi/8)).
- Because of this, 8PSK needs roughly 3 to 3.5 dB more Eb/N0 than BPSK for the same BER.

**Gray mapping**
- Neighbouring 8PSK points differ by only one bit. Most symbol errors go to a neighbouring point, so each costs about one bit error.
- This is why the theoretical formula (symbol error rate divided by 3) fits the simulation well.

**Comparison**
- BPSK is better in power efficiency (lower BER at the same Eb/N0).
- 8PSK is better in bandwidth efficiency (3 bits per symbol instead of 1).
- The choice depends on whether the system is limited by power or by bandwidth.

## Files delivered

- `mapper_BPSK.m`, `demapper_BPSK.m`
- `mapper_8PSK.m`, `demapper_8PSK.m`
- `Fahd_test.m` (simulation script)
- `results/BER_BPSK_8PSK.png` (simulation and theory curves)
