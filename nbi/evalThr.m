% create Signal of Interest(SoI)
% BPSK Mod + Pulse Shaping(RC)

close all;
clear all;


SNR = zeros(1,10);
BER = zeros(1,10);
BERi = zeros(1,10);


for i = 1:10
    
    std = 10^(-8+i);
    SNR(i) = 10*log(1/std)/log(10);
    
    opt   = 'fftThr';
    % opt   = 'kayEst'
    
    
    Nb    = 2000;  % num of bits
    xb    = sign(randn([1,Nb]));  % BPSK
    x_mod = xb;
    
    % ========= pulse shape (RC Raised Cosine)  ====
    sps   = 4;    % sample per symbol
    span  = 4;    % duration
    beta  = 0.25;
    shape = 'sqrt';
    p     = rcosdesign(beta,span,sps,shape);
    rCosSpec =  fdesign.pulseshaping(sps,'Raised Cosine',...
        'Nsym,Beta',span,0.25);
    rCosFlt = design ( rCosSpec );
    rCosFlt.Numerator = rCosFlt.Numerator / max(rCosFlt.Numerator);
    upsampled = upsample( x_mod, sps); % upsample
    FltDelay = (span*sps)/2;           % shift
    temp = filter(rCosFlt , [ upsampled , zeros(1,FltDelay) ] );
    x_ps = temp(9:end);        % to be fixed
    
    %==== [skipped single carrier upgrade] ==============
    fs = 10000;  % sample rate
    dt = 1/fs;  %  min time step duration
    t  = 1:Nb*sps;
    
    %====== additive nbi signal (on the channel) ====
    f_nbi = 770;
    w_nbi = 2*pi*f_nbi;  %
    A_nbi = 10.0;
    phi_nbi = 0.0*pi;
    nbi = A_nbi * cos(w_nbi*t*dt + phi_nbi);
    
    % ==== additive white noise ====
%     std = 0.001;
    n = std * randn(1, Nb*sps);
    
    rx = x_ps + nbi + n;  % received signal
    
    %==== [skipped single carrier downgrade] ==============
    % x_down = 2 * demod(x_up,fc,fs);
    
    % ==== [skipped matching filter] ==========
    % R = conv(rx,p);
    % R = R(18:end);
    
    % downsample for pulse shape
    x_ds = downsample(rx, sps);
    
    
    % ==== narrowband mitigation ==========
    if opt == 'fftThr'
        % === method 1: fft threshold
        threshold =  2 * max(abs(fft(p)));
        x_end = fftThr(x_ds, threshold);
        
    elseif opt == 'kayEst'
        % === method 2: Kay Estimation ==========
        f_h = kayEst(rx,fs);  % NOTICE x_ds would fail
        t  = 1:sps:Nb*sps;
        x_end = x_ds - A_nbi * cos(f_h*2*pi*t*dt);  % assume A_nbi known, phase known
        
    else
        disp('wrong opt, choose among fftThr, kayEst');
    end
    
    % ======= evaluation ======
    x_h = sign(x_end);   % BPSK dector
    BER(i) = sum(xb ~= x_h)/Nb;
    
    BERi(i) = qfunc(sqrt(2*1/std));
    
end

BER
BERi


figure;
plot(SNR,BER,'-o','LineWidth',2);
hold on;
plot(SNR,BERi,'-*','LineWidth',2); 
grid on;
xlabel('SNR')
ylabel('BER')
legend('fftThr','ideal')

