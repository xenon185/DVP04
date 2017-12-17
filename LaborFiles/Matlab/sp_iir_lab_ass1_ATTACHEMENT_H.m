clear all
clc

%% DVP4 Filterentwurf IIR
% Filter Parameter

Fs = 8000;              % Sample frequency [Hz]
fg_passband1 = 1950/2;     % Passband corner frequency [Hz]
fg_passband2 = 4000-(1950/2);     % Passband corner frequency [Hz]
fg_stopband1 = 3000/2;     % Stopband corner frequency [Hz]
fg_stopband2 = 4000-(3000/2);     % Stopband corner frequency [Hz]

Wp = [fg_passband1 fg_passband2]/(Fs/2);% Passband corner frequency normalized to 1/2 sample frequency
Ws = [fg_stopband1 fg_stopband2]/(Fs/2);% Stopband corner frequency normalized to 1/2 sample frequency
Rs = 40;                % Stopband attenuation [db]
Rp = 0.01;              % Passband ripple [db]


%% IIR LP-Filterentwurf: ellipord & ellip ATTACHMENT H

% ellipord calculates the minimum order of a digital or analog elliptic filter 
% required to meet a set of filter design specifications.
% n -> returns the lowest order
% Wp -> Cutoff frequencies
[n_ellipord_LP, Wp_ellipord_LP] = ellipord(Wp, Ws, Rp, Rs); 

% Returns the transfer function coefficients of an nth-order lowpass digital elliptic filter 
% with normalized passband edge frequency Wp
[b_ellip_LP, a_ellip_LP] = ellip(n_ellipord_LP, Rp, Rs, Wp_ellipord_LP, 'stop');

% Convert digital filter transfer function data to second-order sections form
% sos -> matrix with second-order section
% g -> gain factor
[sos_ellip_LP, g_ellip_LP] = tf2sos(b_ellip_LP, a_ellip_LP);

%%

% Amplitudengang
[amp_ellip_LP , freq_ellip_LP ] = freqz(b_ellip_LP, a_ellip_LP, 512, Fs);
figure (1);
subplot (211);
plot (freq_ellip_LP ,(20* log10 (abs(amp_ellip_LP ))));
grid on;
title (' Amplitudengang  IIR  Tiefpass  ( Elliptic ) in dB ');
xlabel ('Frequency  (Hz)');
ylabel ('Magnitude  (dB)');
subplot (212);
plot (freq_ellip_LP ,abs(amp_ellip_LP ));
grid on;
title (' Amplitudengang  IIR  Tiefpass  ( Elliptic ) mit  absoluter   Skala ');
xlabel ('Frequency  (Hz)');

% IIR Filter with stages, scatter gain factor over the stages
% column -> spalte, row -> zeile
[ sos_ellip_LP_column , sos_ellip_LP_row ] = size(sos_ellip_LP);
% calculate the iir filter order
sos_ellip_LP_order = sos_ellip_LP_column;

% scatter the gain factor over the stages
% n-square of the factor, n=stages / nthroot->n-square
% Transponierte Direktstruktur II <- g scatter only over coeff b
for(k=1: sos_ellip_LP_column)
    for(m=1: (sos_ellip_LP_row/2))
        sos_ellip_LP(k,m)= sos_ellip_LP(k,m)* nthroot (g_ellip_LP, sos_ellip_LP_order );
    end
end

b_sos_ellip_LP = sos_ellip_LP (:,1:3);
a_sos_ellip_LP = sos_ellip_LP (:,4:6);

[amp_ellip1_LP , freq_ellip1_LP] = freqz(b_sos_ellip_LP(1,:) ,[a_sos_ellip_LP(1,1) a_sos_ellip_LP(1,2:3)], 512, Fs);
[amp_ellip2_LP , freq_ellip2_LP] = freqz(b_sos_ellip_LP(2,:) ,[a_sos_ellip_LP(2,1) a_sos_ellip_LP(2,2:3)], 512, Fs);

% figure(2);
% subplot(211);
% plot(freq_ellip1_LP ,( 20* log10 (abs( amp_ellip1_LP )) + 20* log10 (abs( amp_ellip2_LP )) ) );
% grid on;
% title (' Amplitudengang  IIR  Tiefpass  ( Elliptic ) in dB ( Kaskadierung )');
% xlabel ('Frequency  (Hz)');
% ylabel ('Magnitude  (dB)');
% subplot (2 ,1 ,2);
% plot (freq_ellip1_LP ,abs( amp_ellip1_LP .* amp_ellip2_LP ));
% grid on;
% title (' Amplitudengang  IIR  Tiefpass  ( Elliptic ) mit  absoluter   Skala  ( Kaskadierung )');
% xlabel ('Frequency  (Hz)');
