function r = channel(sig,ebno,chanType, sampsPerSym, bitsPerSym)
    if(strcmp(chanType,'AWGN') || strcmp(chanType,'awgn'))
        r = sig;
    else
        error(sprintf('Channel Type %s not implemented',chanType));
    end
    
    SNR = ebno - 10*log10(sampsPerSym) + 10*log10(bitsPerSym);
    std_dev = 10^(-SNR/20)*rms(sig)/sqrt(2);
    n = std_dev*randn(size(sig)) + 1j*std_dev*randn(size(sig));

%   for CMA   
%     Ch = [0.8+j*0.1 .9-j*0.2];
%     Ch = norm(Ch);
%     r = filter(Ch,1,r);
    
    r = r + n;
end

