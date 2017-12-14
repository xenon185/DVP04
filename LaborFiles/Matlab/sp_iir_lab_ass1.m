%% DVP4 Filterentwurf IIR


Fs = 8000;              % Sample frequency [Hz]
fg_passband = 1950;     % Passband corner frequency [Hz]
fg_stopband = 3000;     % Stopband corner frequency [Hz]

Wp = fg_passband/(Fs/2);% Passband corner frequency normalized to 1/2 sample frequency
Ws = fg_stopband/(Fs/2);% Stopband corner frequency normalized to 1/2 sample frequency
Rs = 40;                % Stopband attenuation [db]
Rp = 0.01;              % Passband ripple [db]


%% IIR LP-Filterentwurf: ellipord & ellip

% ellipord calculates the minimum order of a digital or analog elliptic filter 
% required to meet a set of filter design specifications.
% n -> returns the lowest order
% Wp -> Cutoff frequencies
[n_ellipord, Wp_ellipord] = ellipord(Wp, Ws, Rp, Rs); 

% Returns the transfer function coefficients of an nth-order lowpass digital elliptic filter 
% with normalized passband edge frequency Wp
[b_ellip, a_ellip] = ellip(n_ellipord, Rp, Rs, Wp_ellipord);

% Convert digital filter transfer function data to second-order sections form
% sos -> matrix with second-order section
% g -> gain factor
[sos_ellip, g_ellip] = tf2sos(b_ellip, a_ellip);

% Amplitudengang
[amp , freq ] = freqz(b_ellip, a_ellip, 512, Fs);
figure (1);
subplot (211);
plot (freq ,(20* log10 (abs(amp ))));
grid on;
title (' Amplitudengang  IIR  Tiefpass  ( Elliptic ) in dB ');
xlabel ('Frequency  (Hz)');
ylabel ('Magnitude  (dB)');
subplot (212);
plot (freq ,abs(amp ));
grid on;
title (' Amplitudengang  IIR  Tiefpass  ( Elliptic ) mit  absoluter   Skala ');
xlabel ('Frequency  (Hz)');

% IIR Filter with stages, scatter gain factor over the stages
% column -> spalte, row -> zeile
[ sos_ellip_column , sos_ellip_row ] = size(sos_ellip);
% calculate the iir filter order
iir_ellip_order = (sos_ellip_row/2)-1; % angucken!!!!!!!!!!!!!!!!!!!

% scatter the gain factor over the stages
% n-square of the factor, n=stages / nthroot->n-square
% Transponierte Direktstruktur II <- g scatter only over coeff b
for(k=1: sos_ellip_column)
    for(m=1: (sos_ellip_row/2))
        sos_ellip(k,m)= sos_ellip(k,m)* nthroot (g_ellip, iir_ellip_order ); % angucken!!!!!!!!!!!!!!!!!!!
    end
end

num_ellip = sos_ellip (:,1:3);
den_ellip = sos_ellip (:,4:6);

[amp_ellip1 , f_ellip1] = freqz(num_ellip(1,:) ,[den_ellip(1,1) den_ellip(1,2:3)]);
[amp_ellip2 , f_ellip2] = freqz(num_ellip(2,:) ,[den_ellip(2,1) den_ellip(2,2:3)]);

figure(2);
subplot(211);
plot(freq ,( 20* log10 (abs( amp_ellip1 )) + 20* log10 (abs( amp_ellip2 )) ) );
grid on;
title (' Amplitudengang  IIR  Tiefpass  ( Elliptic ) in dB ( Kaskadierung )');
xlabel ('Frequency  (Hz)');
ylabel ('Magnitude  (dB)');
subplot (2 ,1 ,2);
plot (freq ,abs( amp_ellip1 .* amp_ellip2 ));
grid on;
title (' Amplitudengang  IIR  Tiefpass  ( Elliptic ) mit  absoluter   Skala  ( Kaskadierung )');
xlabel ('Frequency  (Hz)');

%% Koeffizienten Ausgabe Ellip

% create header file IIR_LP_ellip_cheby1.h
% assumption: IIR filter coefficients are stored in num_IIR, den_IIR and that
% the filter has a degree of N_IIR_LP
filnam = fopen('IIR_LP_ellip.h', 'w'); % generate include-file
fprintf(filnam,'#define N_IIR_LP %d\n', ((sos_ellip_row/2)-1));
fprintf(filnam,'short num_ellip[N_IIR_LP][VALUE]=\n');
for i=1 : (sos_ellip_column)
    fprintf(filnam, '{');
    for j=1 : (sos_ellip_row/2)
        fprintf(filnam,' %6.0d', round(num_ellip(i,j)*32768) );
        if j < (sos_ellip_row/2)
            fprintf(filnam, ',');
        end
        j = j + 1;
    end
    j=0;
	fprintf(filnam, '},\n');
end
fprintf(filnam,'\n');
fprintf(filnam,'short den_ellip[N_IIR_LP][VALUE]=\n');
for i=1 : (sos_ellip_column)
    fprintf(filnam, '{');
    for j=1 : (sos_ellip_row/2)
        fprintf(filnam,' %6.0d', round(den_ellip(i,j)*32768) );
        if j < (sos_ellip_row/2)
            fprintf(filnam, ',');
        end
        j = j + 1;
    end
    j=0;
	fprintf(filnam, '},\n');
end

fclose(filnam); 


%% IIR LP-Filterentwurf: cheb1ord & cheby1

% cheb1ord calculates the minimum order of a digital or analog Chebyshev Type I filter 
% required to meet a set of filter design specifications.
% n -> returns the lowest order
% Wp -> Cutoff frequencies
[n_cheb1ord, Wp_cheb1ord] = cheb1ord(Wp, Ws, Rp, Rs);

% Returns the transfer function coefficients of an nth-order lowpass digital Chebyshev Type I filter 
% with normalized passband edge frequency Wp and Rp decibels of peak-to-peak passband ripple.
[b_cheby1, a_cheby1] = cheby1(n_cheb1ord, Rp, Wp_cheb1ord);

% Convert digital filter transfer function data to second-order sections form
% sos -> matrix with second-order section
% g -> gain factor
[sos_cheby1, g_cheby1] = tf2sos(b_cheby1, a_cheby1);


% Amplitudengang
[amp_cheby , freq_cheby ] = freqz(b_cheby1, a_cheby1, 512, Fs);
figure (3);
subplot (211);
plot (freq_cheby ,(20* log10 (abs(amp_cheby ))));
grid on;
title (' Amplitudengang  IIR  Tiefpass  ( Cheby ) in dB ');
xlabel ('Frequency  (Hz)');
ylabel ('Magnitude  (dB)');
subplot (212);
plot (freq_cheby ,abs(amp_cheby ));
grid on;
title (' Amplitudengang  IIR  Tiefpass  ( Cheby ) mit  absoluter   Skala ');
xlabel ('Frequency  (Hz)');

% IIR Filter with stages, scatter gain factor over the stages
% column -> spalte, row -> zeile
[ sos_cheby1_column , sos_cheby1_row ] = size(sos_cheby1);
% calculate the iir filter order
iir_cheby1_order = (sos_cheby1_row/2);

% scatter the gain factor over the stages
% n-square of the factor, n=stages / nthroot->n-square
% Transponierte Direktstruktur II <- g scatter only over coeff b
for(k=1: sos_cheby1_column)
    for(m=1: (sos_cheby1_row/2))
        sos_cheby1(k,m)= sos_cheby1(k,m)* nthroot (g_cheby1, iir_cheby1_order ); % 
    end
end

num_cheby1 = sos_cheby1 (:,1:3);
den_cheby1 = sos_cheby1 (:,4:6);

[amp_cheby11 , f_cheby11] = freqz(num_cheby1(1,:) ,[den_cheby1(1,1) den_cheby1(1,2:3)]);
[amp_cheby12 , f_cheby12] = freqz(num_cheby1(2,:) ,[den_cheby1(2,1) den_cheby1(2,2:3)]);

figure(4);
subplot(211);
plot(freq ,( 20* log10 (abs( amp_cheby11 )) + 20* log10 (abs( amp_cheby12 )) ) );
grid on;
title (' Amplitudengang  IIR  Tiefpass  ( Cheby ) in dB ( Kaskadierung )');
xlabel ('Frequency  (Hz)');
ylabel ('Magnitude  (dB)');
subplot (2 ,1 ,2);
plot (freq ,abs( amp_cheby11 .* amp_cheby12 ));
grid on;
title (' Amplitudengang  IIR  Tiefpass  ( Cheby ) mit  absoluter   Skala  ( Kaskadierung )');
xlabel ('Frequency  (Hz)');

%% Koeffizienten Ausgabe Cheby1

% create header file IIR_LP_ellip_cheby1.h
% assumption: IIR filter coefficients are stored in num_IIR, den_IIR and that
% the filter has a degree of N_IIR_LP
filnam = fopen('IIR_LP_cheby1.h', 'w'); % generate include-file
fprintf(filnam,'#define N_IIR_LP %d\n', (sos_cheby1_row/2));
fprintf(filnam,'short num_cheby1[N_IIR_LP]=\n');
for i=1 : (sos_cheby1_column)
    fprintf(filnam, '{');
    for j=1 : (sos_cheby1_row/2)
        fprintf(filnam,' %6.0d', round(num_cheby1(i,j)*32768) );
        if j < (sos_cheby1_row/2)
            fprintf(filnam, ',');
        end
        j = j + 1;
    end
    j=0;
	fprintf(filnam, '},\n');
end
fprintf(filnam,'\n');
fprintf(filnam,'short den_cheby1[N_IIR_LP][VALUE]=\n');
for i=1 : (sos_cheby1_column)
    fprintf(filnam, '{');
    for j=1 : (sos_cheby1_row/2)
        fprintf(filnam,' %6.0d', round(den_cheby1(i,j)*32768) );
        if j < (sos_cheby1_row/2)
            fprintf(filnam, ',');
        end
        j = j + 1;
    end
    j=0;
	fprintf(filnam, '},\n');
end

fclose(filnam); 

%% IIR HP-Filterentwurf: ellipord & ellip

Wp = 1950/( Fs /2); % passband corner frequency
Ws = 3000/( Fs /2); % stopband corner frequency

% ellipord calculates the minimum order of a digital or analog elliptic filter 
% required to meet a set of filter design specifications.
% n -> returns the lowest order
% Wp -> Cutoff frequencies
[n_ellipord_HP, Wp_ellipord_HP] = ellipord(Wp, Ws, Rp, Rs); 

% Returns the transfer function coefficients of an nth-order lowpass digital elliptic filter 
% with normalized passband edge frequency Wp
[b_ellip_HP, a_ellip_HP] = ellip(n_ellipord_HP, Rp, Rs, Wp_ellipord_HP, 'high');

% Convert digital filter transfer function data to second-order sections form
% sos -> matrix with second-order section
% g -> gain factor
[sos_ellip_HP, g_ellip_HP] = tf2sos(b_ellip_HP, a_ellip_HP);

% Amplitudengang
[amp_ellip_HP , freq_ellip_HP ] = freqz(b_ellip_HP, a_ellip_HP, 512, Fs);
figure (5);
subplot (211);
plot (freq_ellip_HP ,(20* log10 (abs(amp_ellip_HP ))));
grid on;
title (' Amplitudengang  IIR  Hochpass  ( Elliptic ) in dB ');
xlabel ('Frequency  (Hz)');
ylabel ('Magnitude  (dB)');
subplot (212);
plot (freq_ellip_HP ,abs(amp_ellip_HP ));
grid on;
title (' Amplitudengang  IIR  Hochpass  ( Elliptic ) mit  absoluter   Skala ');
xlabel ('Frequency  (Hz)');

% IIR Filter with stages, scatter gain factor over the stages
% column -> spalte, row -> zeile
[ sos_ellip_HP_column , sos_ellip_HP_row ] = size(sos_ellip_HP);
% calculate the iir filter order
iir_ellip_HP_order = (sos_ellip_HP_row/2)-1;

% scatter the gain factor over the stages
% n-square of the factor, n=stages / nthroot->n-square
% Transponierte Direktstruktur II <- g scatter only over coeff b
for(k=1: sos_ellip_HP_column)
    for(m=1: (sos_ellip_HP_row/2))
        sos_ellip_HP(k,m)= sos_ellip_HP(k,m)* nthroot (g_ellip_HP, iir_ellip_HP_order );
    end
end

num_ellip_HP = sos_ellip_HP (:,1:3);
den_ellip_HP = sos_ellip_HP (:,4:6);

[amp_ellip1_HP , f_ellip1_HP] = freqz(num_ellip_HP(1,:) ,[den_ellip_HP(1,1) den_ellip_HP(1,2:3)]);
[amp_ellip2_HP , f_ellip2_HP] = freqz(num_ellip_HP(2,:) ,[den_ellip_HP(2,1) den_ellip_HP(2,2:3)]);

figure(6);
subplot(211);
plot(f_ellip1_HP ,( 20* log10 (abs( amp_ellip1_HP )) + 20* log10 (abs( amp_ellip2_HP )) ) );
grid on;
title (' Amplitudengang  IIR  Hochpass  ( Elliptic ) in dB ( Kaskadierung )');
xlabel ('Frequency  (Hz)');
ylabel ('Magnitude  (dB)');
subplot (212);
plot (f_ellip1_HP ,abs( amp_ellip1_HP .* amp_ellip2_HP ));
grid on;
title (' Amplitudengang  IIR  Hochpass  ( Elliptic ) mit  absoluter   Skala  ( Kaskadierung )');
xlabel ('Frequency  (Hz)');

%% Koeffizienten Ausgabe Ellip HP

% create header file IIR_HP_ellip_cheby1.h
% assumption: IIR filter coefficients are stored in num_IIR, den_IIR and that
% the filter has a degree of N_IIR_LP
filnam = fopen('IIR_HP_ellip.h', 'w'); % generate include-file
fprintf(filnam,'#define N_IIR_LP %d\n', (sos_ellip_HP_row/2));
fprintf(filnam,'short num_ellip_hp[N_IIR_LP][VALUE]=\n');
for i=1 : (sos_ellip_HP_column)
    fprintf(filnam, '{');
    for j=1 : (sos_ellip_HP_row/2)
        fprintf(filnam,' %6.0d', round(num_ellip_HP(i,j)*32768) );
        if j < (sos_ellip_HP_row/2)
            fprintf(filnam, ',');
        end
        j = j + 1;
    end
    j=0;
	fprintf(filnam, '},\n');
end
fprintf(filnam,'\n');
fprintf(filnam,'short den_ellip_hp[N_IIR_LP][VALUE]=\n');
for i=1 : (sos_ellip_HP_column)
    fprintf(filnam, '{');
    for j=1 : (sos_ellip_HP_row/2)
        fprintf(filnam,' %6.0d', round(den_ellip_HP(i,j)*32768) );
        if j < (sos_ellip_HP_row/2)
            fprintf(filnam, ',');
        end
        j = j + 1;
    end
    j=0;
	fprintf(filnam, '},\n');
end

fclose(filnam); 

%% Zeit Simulation

fs = 8000;
Ns = 256;
t =0:1/ fs :(1/ fs )*(Ns -1);
x_n = 0;
x_n = x_n + 0.2 * cos (2* pi* 500 *t);
x_n = x_n + 0.2 *cos (2* pi* 1250 *t);
x_n = x_n + 0.2 *cos (2* pi* 2000 *t);
x_n = x_n + 0.2 *cos (2* pi* 2500 *t);
x_n = x_n + 0.2 *cos (2* pi* 3500 *t);
% convert H(z) to equivalent second - order section representation
[sos_sim ,g_sim] = tf2sos (b_ellip_HP,a_ellip_HP);
% filter with cascaded filter
y_n = x_n;
for i=1: size (sos_sim ,1)
y_n = filter (sos_sim(i ,1:3) , sos_sim(i ,4:6) , y_n );
end
y_n = y_n*g_sim;
% original filter to compare with cascaded filter
y_n2 = x_n;
y_n2 = filter (b_ellip_HP,a_ellip_HP, y_n2 );
%%
figure (7);
% input signal
plot (t,x_n );
grid on;
title (' Eingangssignal ');
xlabel ('Zeit  (s)');
%%
figure (8);
% filtered with original filter
plot (t, y_n2 );
grid on;
title (' Ausgangssignal   nach   direkter   Filterung ');
xlabel ('Zeit  (s)');
%%
figure (9);
% filtered with cascade - filter
plot (t,y_n );
grid on;
title (' Ausgangssignal   nach   kaskadierter   Filterung ');
xlabel ('Zeit  (s)');
%%
figure (10);
% input spectrum
xfftmag =( abs(fft(x_n ,Ns ))); % Compute spectrum of input signal .
xfftmagh = xfftmag (1: length ( xfftmag )/2);
% Plot only the first half of FFT , since second half is mirror imag
f =[1:1: length( xfftmagh )]* fs/Ns; % Make freq array from 0 Hz to Fs /2 Hz.
plot (f, xfftmagh ); % Plot frequency spectrum of input signal
grid on;
title (' Eingangsspektrum ');
xlabel ('freq  (Hz)');
%%
figure (11);
% filtered with original filter
yfftmag =( abs(fft(y_n2 ,Ns )));
yfftmagh = yfftmag (1: length ( yfftmag )/2);
% Plot only the first half of FFT , since second half is mirror image
plot (f, yfftmagh ); % Plot frequency spectrum of input signal
grid on;
title (' Ausgangsspektrum   nach   direkter   Filterung ');
xlabel ('freq  (Hz)');
%%
figure (12);
% filtered with cascade - filter
yfftmag =( abs(fft(y_n ,Ns )));
yfftmagh = yfftmag (1: length ( yfftmag )/2);
% Plot only the first half of FFT , since second half is mirror image
plot (f, yfftmagh ); % Plot frequency spectrum of input signal
grid on;
title (' Ausgangsspektrum   nach   kaskadierter   Filterung ');
xlabel ('freq  (Hz)');