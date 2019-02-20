% create Signal of Interest(SoI)
% BPSK Mod + Pulse Shaping(RC)

close all;
clear all;

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

% toolbox
% rCosSpec =  fdesign.pulseshaping(sps,'Raised Cosine',...
%     'Nsym,Beta',span,0.25);
% rCosFlt = design ( rCosSpec );
% rCosFlt.Numerator = rCosFlt.Numerator / max(rCosFlt.Numerator);
% upsampled = upsample( x_mod, sps); % upsample
% FltDelay = (span*sps)/2;           % shift
% temp = filter(rCosFlt , [ upsampled , zeros(1,FltDelay) ] );



x_mod = [x_mod, zeros(1,(sps-1)*span)];
x_mod = reshape(x_mod, [])
% upsampled = upsample( x_mod, sps);  % 8000
% upsampled = [ zeros(1,sps*span), upsampled ];  % 8016
temp = conv(upsampled, p);  % 8016+17-1=8032
%temp = temp(17:end);

x_ps = temp(18:end-15);        % to be fixed
 
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
std = 0.001;
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
BER = sum(xb ~= x_h)/Nb






