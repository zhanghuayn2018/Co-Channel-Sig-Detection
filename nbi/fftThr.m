function y = fftThr(x,threshold)
% Input: x - signal vector
%        threshold - scalar, max thr in frequency domain
% Output: y - processed vector
    X = fft(x);
    for i = 1:length(x)
        if abs(X(i)) > threshold
            X(i) = X(i)*threshold/abs(X(i));
        end
    end
    y = ifft(X);
end