function [formants, x] = find_formants(audio, Fs, secs, splay)

%%
% Use LPC to gather formants
% Code mostly verbatim from:
% http://www.mathworks.com/help/signal/ug/formant-estimation-with-lpc-coefficients.html
%
% Rounds the formants to the nearest 10
% :audio: audio file read in with audioread
% :Fs:    sample rate for audio file
% :secs:  position (in seconds) around which to sample data
% :splay: amount (in seconds) around secs which to sample
%%

start_secs = secs - splay;
end_secs = secs + splay;

dt = 1/Fs;
I0 = round(start_secs/dt);
Iend = round(end_secs/dt);

% sometimes this doesn't work on the first try...
try
    x = audio(I0:Iend);
catch
    try
        x = audio(I0:end);
    catch
        splay_i = round(splay/dt);
        x = audio(end-splay_i:end);
    end
end

% Window the speech segment using a Hamming window.

x1 = x.*hamming(length(x));

% Apply a pre-emphasis filter. The pre-emphasis filter is a highpass 
% all-pole (AR(1)) filter.

preemph = [1 0.63];
x1 = filter(1,preemph,x1);

% Obtain the linear prediction coefficients. To specify the model order, 
% use the general rule that the order is two times the expected number of 
% formants plus 2. In the frequency range, [0,|Fs|/2], you expect three 
% formants. Therefore, set the model order equal to 8. Find the roots of 
% the prediction polynomial returned by lpc.

try
    A = lpc(x1,8);
    rts = roots(A);
catch
    % Ahhh. Oh well. Just give up now
    formants = zeros(1,3);
    return 
end

% Because the LPC coefficients are real-valued, the roots occur in 
% complex conjugate pairs. Retain only the roots with one sign for the 
% imaginary part and determine the angles corresponding to the roots.

rts = rts(imag(rts)>=0);
angz = atan2(imag(rts),real(rts));

% Convert the angular frequencies in rad/sample represented by the angles 
% to Hz and calculate the bandwidths of the formants.

% The bandwidths of the formants are represented by the distance of the 
% prediction polynomial zeros from the unit circle.

[frqs,indices] = sort(angz.*(Fs/(2*pi)));
bw = -1/2*(Fs/(2*pi))*log(abs(rts(indices)));

% Use the criterion that formant frequencies should be greater than 90 Hz 
% with bandwidths less than 400 Hz to determine the formants.

formants = zeros(1,3);
nn = 1;
for kk = 1:length(frqs)
    if (frqs(kk) > 90 && bw(kk) <400)
        % round to nearest 10
        formants(nn) = roundn(frqs(kk), 1);
        nn = nn+1;
    end
end

end