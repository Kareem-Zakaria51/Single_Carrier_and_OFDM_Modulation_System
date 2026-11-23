
function ber = theoretical_ber(scheme, EbN0_dB)

    g = 10.^(EbN0_dB/10);
    Q = @(x) 0.5*erfc(x/sqrt(2));

    switch lower(scheme)

        case {'bpsk','qpsk','qpsk_gray'}
            ber = Q(sqrt(2*g));

        case 'qpsk_non_gray'
            p = Q(sqrt(2*g));
            ber = 1.5*p - p.^2;

        case 'bfsk'
            ber = Q(sqrt(g));

        case '8psk'
            ber = (2/3)*Q(sqrt(6*g)*sin(pi/8));

        case '16qam'
            ber = (3/8)*erfc(sqrt(0.4*g));

        otherwise
            error('Unknown modulation scheme: %s', scheme);
    end
end
