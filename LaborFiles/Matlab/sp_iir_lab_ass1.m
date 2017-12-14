clear all
clc

%% DVP4 Filterentwurf IIR
% Filter Parameter

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
[n_ellipord_LP, Wp_ellipord_LP] = ellipord(Wp, Ws, Rp, Rs); 

% Returns the transfer function coefficients of an nth-order lowpass digital elliptic filter 
% with normalized passband edge frequency Wp
[b_ellip_LP, a_ellip_LP] = ellip(n_ellipord_LP, Rp, Rs, Wp_ellipord_LP);

% Convert digital filter transfer function data to second-order sections form
% sos -> matrix with second-order section
% g -> gain factor
[sos_ellip_LP, g_ellip_LP] = tf2sos(b_ellip_LP, a_ellip_LP);

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

figure(2);
subplot(211);
plot(freq_ellip1_LP ,( 20* log10 (abs( amp_ellip1_LP )) + 20* log10 (abs( amp_ellip2_LP )) ) );
grid on;
title (' Amplitudengang  IIR  Tiefpass  ( Elliptic ) in dB ( Kaskadierung )');
xlabel ('Frequency  (Hz)');
ylabel ('Magnitude  (dB)');
subplot (2 ,1 ,2);
plot (freq_ellip1_LP ,abs( amp_ellip1_LP .* amp_ellip2_LP ));
grid on;
title (' Amplitudengang  IIR  Tiefpass  ( Elliptic ) mit  absoluter   Skala  ( Kaskadierung )');
xlabel ('Frequency  (Hz)');

%% Koeffizienten Ausgabe Ellip LP

% create header file IIR_LP_ellip_cheby1.h
% assumption: IIR filter coefficients are stored in num_IIR, den_IIR and that
% the filter has a degree of N_IIR_LP
filnam = fopen('IIR_ellip_LP.h', 'w'); % generate include-file
fprintf(filnam,'#define N_IIR_ELLIP_LP %d\n', sos_ellip_LP_row/2);
fprintf(filnam,'#define ORDER_ELLIP_LP %d\n', (sos_ellip_LP_order));
fprintf(filnam,'#define VALUE %d\n', (sos_ellip_LP_row/2));
fprintf(filnam,'\n');
fprintf(filnam,'short B_ELLIP_LP[N_IIR__ELLIP_LP][VALUE]= {\n');
for i=1 : (sos_ellip_LP_column)
    fprintf(filnam, '{');
    for j=1 : (sos_ellip_LP_row/2)
        fprintf(filnam,' %6.0d', round(b_sos_ellip_LP(i,j)*32768) );
        if j < (sos_ellip_LP_row/2)
            fprintf(filnam, ',');
        end
        j = j + 1;
    end
    if (i<sos_ellip_LP_column)
        fprintf(filnam, '},\n');
    end
    j=0;
end

fprintf(filnam,'}};\n');
fprintf(filnam,'short A_ELLIP_LP[N_IIR__ELLIP_LP][VALUE]= {\n');
for i=1 : (sos_ellip_LP_column)
    fprintf(filnam, '{');
    for j=1 : (sos_ellip_LP_row/2)
        fprintf(filnam,' %6.0d', round(a_sos_ellip_LP(i,j)*32768) );
        if j < (sos_ellip_LP_row/2)
            fprintf(filnam, ',');
        end
        j = j + 1;
    end
    if (i<sos_ellip_LP_column)
        fprintf(filnam, '},\n');
    end
    j=0;
end
fprintf(filnam,'}};\n');
fclose(filnam); 


%% IIR LP-Filterentwurf: cheb1ord & cheby1

% cheb1ord calculates the minimum order of a digital or analog Chebyshev Type I filter 
% required to meet a set of filter design specifications.
% n -> returns the lowest order
% Wp -> Cutoff frequencies
[n_cheb1ord_LP, Wp_cheb1ord_LP] = cheb1ord(Wp, Ws, Rp, Rs);

% Returns the transfer function coefficients of an nth-order lowpass digital Chebyshev Type I filter 
% with normalized passband edge frequency Wp and Rp decibels of peak-to-peak passband ripple.
[b_cheby1_LP, a_cheby1_LP] = cheby1(n_cheb1ord_LP, Rp, Wp_cheb1ord_LP);

% Convert digital filter transfer function data to second-order sections form
% sos -> matrix with second-order section
% g -> gain factor
[sos_cheby1_LP, g_cheby1_LP] = tf2sos(b_cheby1_LP, a_cheby1_LP);


% Amplitudengang
[amp_cheby_LP , freq_cheby_LP ] = freqz(b_cheby1_LP, a_cheby1_LP, 512, Fs);
figure (3);
subplot (211);
plot (freq_cheby_LP ,(20* log10 (abs(amp_cheby_LP ))));
grid on;
title (' Amplitudengang  IIR  Tiefpass  ( Cheby ) in dB ');
xlabel ('Frequency  (Hz)');
ylabel ('Magnitude  (dB)');
subplot (212);
plot (freq_cheby_LP ,abs(amp_cheby_LP ));
grid on;
title (' Amplitudengang  IIR  Tiefpass  ( Cheby ) mit  absoluter   Skala ');
xlabel ('Frequency  (Hz)');

% IIR Filter with stages, scatter gain factor over the stages
% column -> spalte, row -> zeile
[ sos_cheby1_LP_column , sos_cheby1_LP_row ] = size(sos_cheby1_LP);
% calculate the iir filter order
sos_cheby1_LP_order = sos_cheby1_LP_column;

% scatter the gain factor over the stages
% n-square of the factor, n=stages / nthroot->n-square
% Transponierte Direktstruktur II <- g scatter only over coeff b
for(k=1: sos_cheby1_LP_column)
    for(m=1: (sos_cheby1_LP_row/2))
        sos_cheby1_LP(k,m)= sos_cheby1_LP(k,m)* nthroot (g_cheby1_LP, sos_cheby1_LP_order ); % 
    end
end

b_sos_cheby1_LP = sos_cheby1_LP (:,1:3);
a_sos_cheby1_LP = sos_cheby1_LP (:,4:6);

[amp_cheby11_LP , f_cheby11_LP] = freqz(b_sos_cheby1_LP(1,:) ,[a_sos_cheby1_LP(1,1) a_sos_cheby1_LP(1,2:3)], 512, Fs);
[amp_cheby12_LP , f_cheby12_LP] = freqz(b_sos_cheby1_LP(2,:) ,[a_sos_cheby1_LP(2,1) a_sos_cheby1_LP(2,2:3)], 512, Fs);

figure(4);
subplot(211);
plot(f_cheby11_LP ,( 20* log10 (abs( amp_cheby11_LP )) + 20* log10 (abs( amp_cheby12_LP )) ) );
grid on;
title (' Amplitudengang  IIR  Tiefpass  ( Cheby ) in dB ( Kaskadierung )');
xlabel ('Frequency  (Hz)');
ylabel ('Magnitude  (dB)');
subplot (2 ,1 ,2);
plot (f_cheby12_LP ,abs( amp_cheby11_LP .* amp_cheby12_LP ));
grid on;
title (' Amplitudengang  IIR  Tiefpass  ( Cheby ) mit  absoluter   Skala  ( Kaskadierung )');
xlabel ('Frequency  (Hz)');

%% Koeffizienten Ausgabe Cheby1

% create header file IIR_LP_ellip_cheby1.h
% assumption: IIR filter coefficients are stored in num_IIR, den_IIR and that
% the filter has a degree of N_IIR_LP
filnam = fopen('IIR_cheby1_LP.h', 'w'); % generate include-file
fprintf(filnam,'#define N_IIR_CHEBY1_LP %d\n', sos_cheby1_LP_row/2);
fprintf(filnam,'#define ORDER_CHEBY1_LP %d\n', (sos_cheby1_LP_order));
fprintf(filnam,'#define VALUE %d\n', (sos_cheby1_LP_row/2));
fprintf(filnam,'\n');
fprintf(filnam,'short B_CHEBY_LP[N_IIR__ELLIP_LP][VALUE]= {\n');
for i=1 : (sos_cheby1_LP_column)
    fprintf(filnam, '{');
    for j=1 : (sos_cheby1_LP_row/2)
        fprintf(filnam,' %6.0d', round(b_sos_cheby1_LP(i,j)*32768) );
        if j < (sos_cheby1_LP_row/2)
            fprintf(filnam, ',');
        end
        j = j + 1;
    end
    if (i<sos_cheby1_LP_column)
        fprintf(filnam, '},\n');
    end
    j=0;
end

fprintf(filnam,'}};\n');
fprintf(filnam,'short A_CHEBY_LP[N_IIR__ELLIP_LP][VALUE]= {\n');
for i=1 : (sos_cheby1_LP_column)
    fprintf(filnam, '{');
    for j=1 : (sos_cheby1_LP_row/2)
        fprintf(filnam,' %6.0d', round(a_sos_cheby1_LP(i,j)*32768) );
        if j < (sos_cheby1_LP_row/2)
            fprintf(filnam, ',');
        end
        j = j + 1;
    end
    if (i<sos_cheby1_LP_column)
        fprintf(filnam, '},\n');
    end
    j=0;
end
fprintf(filnam,'}};\n');
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
sos_ellip_HP_order = (sos_ellip_HP_row/2)-1;

% scatter the gain factor over the stages
% n-square of the factor, n=stages / nthroot->n-square
% Transponierte Direktstruktur II <- g scatter only over coeff b
for(k=1: sos_ellip_HP_column)
    for(m=1: (sos_ellip_HP_row/2))
        sos_ellip_HP(k,m)= sos_ellip_HP(k,m)* nthroot (g_ellip_HP, sos_ellip_HP_order );
    end
end

b_sos_ellip_HP = sos_ellip_HP (:,1:3);
a_sos_ellip_HP = sos_ellip_HP (:,4:6);

[amp_ellip1_HP , f_ellip1_HP] = freqz(b_sos_ellip_HP(1,:) ,[a_sos_ellip_HP(1,1) a_sos_ellip_HP(1,2:3)], 512, Fs);
[amp_ellip2_HP , f_ellip2_HP] = freqz(b_sos_ellip_HP(2,:) ,[a_sos_ellip_HP(2,1) a_sos_ellip_HP(2,2:3)], 512, Fs);

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
filnam = fopen('IIR_ellip_HP.h', 'w'); % generate include-file
fprintf(filnam,'#define N_IIR_ELLIP_HP %d\n', sos_ellip_HP_row/2);
fprintf(filnam,'#define ORDER_ELLIP_HP %d\n', (sos_ellip_HP_order));
fprintf(filnam,'#define VALUE %d\n', (sos_ellip_HP_row/2));
fprintf(filnam,'\n');
fprintf(filnam,'short B_ELLIP_HP[N_IIR__ELLIP_HP][VALUE]= {\n');
for i=1 : (sos_ellip_HP_column)
    fprintf(filnam, '{');
    for j=1 : (sos_ellip_HP_row/2)
        fprintf(filnam,' %6.0d', round(b_sos_ellip_HP(i,j)*32768) );
        if j < (sos_ellip_HP_row/2)
            fprintf(filnam, ',');
        end
        j = j + 1;
    end
    if (i<sos_ellip_HP_column)
        fprintf(filnam, '},\n');
    end
    j=0;
end

fprintf(filnam,'}};\n');
fprintf(filnam,'short A_ELLIP_HP[N_IIR__ELLIP_HP][VALUE]= {\n');
for i=1 : (sos_ellip_HP_column)
    fprintf(filnam, '{');
    for j=1 : (sos_ellip_HP_row/2)
        fprintf(filnam,' %6.0d', round(a_sos_ellip_HP(i,j)*32768) );
        if j < (sos_ellip_HP_row/2)
            fprintf(filnam, ',');
        end
        j = j + 1;
    end
    if (i<sos_ellip_HP_column)
        fprintf(filnam, '},\n');
    end
    j=0;
end
fprintf(filnam,'}};\n');
fclose(filnam); 

%% Zeit Simulation

Fs = 8000;
Ns = 256;
t =0:1/ Fs :(1/ Fs )*(Ns -1);
x_n = 0;
x_n = x_n + 0.2 * cos (2* pi* 500 *t);
x_n = x_n + 0.2 *cos (2* pi* 1250 *t);
x_n = x_n + 0.2 *cos (2* pi* 2000 *t);
x_n = x_n + 0.2 *cos (2* pi* 2500 *t);
x_n = x_n + 0.2 *cos (2* pi* 3500 *t);
% convert H(z) to equivalent second - order section representation
% [sos_sim ,g_sim] = tf2sos (b_ellip_HP,a_ellip_HP);
% % filter with cascaded filter
% y_n = x_n;
% for i=1: size (sos_sim ,1)
% y_n = filter (sos_sim(i ,1:3) , sos_sim(i ,4:6) , y_n );
% end
% y_n = y_n*g_sim;
% % original filter to compare with cascaded filter
%y_n2 = x_n;

y_n1 = filter (b_ellip_LP,a_ellip_LP, x_n );
y_n2 = filter (b_cheby1_LP ,a_cheby1_LP, x_n );
y_n3 = filter (b_ellip_HP,a_ellip_HP, x_n );

%%
figure (7);
% input signal
plot (t,x_n );
grid on;
title (' Eingangssignal x_n ');
xlabel ('Zeit  (s)');
%%
figure (8);
% filtered with ellip lp filter
plot (t, y_n1 );
grid on;
title ('Ausgangssignal ELLIP LP Kaskade');
xlabel ('Zeit  (s)');
%%
figure (9);
% filtered with cascade - filter
plot (t,y_n2 );
grid on;
title ('Ausgangssignal ECHEBY LP Kaskade');
xlabel ('Zeit  (s)');

%%
figure (10);
% filtered with cascade - filter
plot (t,y_n3 );
grid on;
title ('Ausgangssignal ELLIP HP Kaskade');
xlabel ('Zeit  (s)');

%%
figure (11);
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
figure (12);
% filtered with original filter
yfftmag =( abs(fft(y_n1 ,Ns )));
yfftmagh = yfftmag (1: length ( yfftmag )/2);
% Plot only the first half of FFT , since second half is mirror image
plot (f, yfftmagh ); % Plot frequency spectrum of input signal
grid on;
title (' Ausgangsspektrum   ELLIP LP Kaskadiert');
xlabel ('freq  (Hz)');
%%
figure (13);
% filtered with cascade - filter
yfftmag =( abs(fft(y_n2 ,Ns )));
yfftmagh = yfftmag (1: length ( yfftmag )/2);
% Plot only the first half of FFT , since second half is mirror image
plot (f, yfftmagh ); % Plot frequency spectrum of input signal
grid on;
title (' Ausgangsspektrum   CHEBY LP Kaskadiert');
xlabel ('freq  (Hz)');

%%
figure (13);
% filtered with cascade - filter
yfftmag =( abs(fft(y_n3 ,Ns )));
yfftmagh = yfftmag (1: length ( yfftmag )/2);
% Plot only the first half of FFT , since second half is mirror image
plot (f, yfftmagh ); % Plot frequency spectrum of input signal
grid on;
title (' Ausgangsspektrum   ELLIP HP Kaskadiert');
xlabel ('freq  (Hz)');