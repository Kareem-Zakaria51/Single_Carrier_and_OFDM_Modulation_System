
function psd_bfsk()

    root = fileparts(mfilename('fullpath'));
    commonDir = fullfile(root,'..','..','Common');
    resultsDir = fullfile(root,'..','results');

    addpath(commonDir);

    if ~exist(resultsDir,'dir')
        mkdir(resultsDir);
    end

    Nbits = 100008;
    Tb = 1;
    L = 32;
    fs = L/Tb;

    t = (0:L-1)'/L*Tb;

    s0 = sqrt(2/Tb)*exp(1j*2*pi*t/Tb);
    s1 = sqrt(2/Tb)*exp(1j*4*pi*t/Tb);

    bits = generate_bits(Nbits);

    x = zeros(L,Nbits);

    x(:,bits==0) = repmat(s0,1,sum(bits==0));
    x(:,bits==1) = repmat(s1,1,sum(bits==1));

    x = x(:);

    % Welch method
    W = 2048;
    overlap = 1024;
    nfft = 4096;

    if exist('pwelch','file') == 2 && ...
       exist('hamming','file') == 2

        [P,f] = pwelch(x,hamming(W),overlap,...
                       nfft,fs,'centered');

    else

        % Toolbox-independent Welch fallback

        win = 0.54 - 0.46*cos( ...
            2*pi*(0:W-1)'/(W-1));

        starts = 1:(W-overlap):(numel(x)-W+1);

        P = zeros(nfft,1);

        for m = 1:numel(starts)

            segment = x(starts(m):starts(m)+W-1);

            X = fftshift(fft(segment.*win,nfft));

            P = P + abs(X).^2/(fs*sum(win.^2));

        end

        P = P/numel(starts);

        f = (-nfft/2:nfft/2-1)'*fs/nfft;

    end

    figure;

    plot(f*Tb,10*log10(P/max(P)),'LineWidth',1.3);

    grid on;

    xlabel('Frequency x T_b');
    ylabel('Normalized PSD (dB)');
    title('PSD of baseband-equivalent BFSK');

    xlim([-4 8]);
    ylim([-60 5]);



end
