function f = kayEst(s,fs)
% Kay's estimation
% Input: s - signal vector
%        fs - sample rate
% Output: f - estimated frequency

    minRes = 5; % min resolution
    N = length(s);
    sum1 = 0;
    sum2 = 0;
    for i = 1:N-1
        sum1 = sum1 + s(i)*s(i+1);
    end
    sum1 = sum1/(N-1);
    for i = 1:N
        sum2 = sum2 + s(i)^2;
    end
    sum2 = sum2/N;

    f = acos(sum1/sum2)/(2*pi)*fs;
    f = round(f/minRes)*minRes; 
    
% LIMITATION: 
% 1. low resolution, min 10Hz 
% 2. single tone 
% 3. high SNR    
    
end
