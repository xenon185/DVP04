%% IIR LP filter ( elliptic )
fs =8000; % sample frequency
% define filter
Wp = 1950/( fs /2); % passband corner frequency
Ws = 3000/( fs /2); % stopband corner frequency
Rp =0.01; % passband ripple in dB
Rs =40; % stopbandripple in dB
% calculate minimum order n needed for required specification
[n,Wp] = ellipord (Wp ,Ws ,Rp ,Rs );
% design elliptic filter (in this case lowpass )
% returns numerator b and denumerator a of H(z)
[b, a] = ellip (n,Rp ,Rs ,Wp );
% display frequency response of given digital filter
[amp , freq ] = freqz (b,a ,512 , fs );
figure (1);
subplot (2 ,1 ,1);
plot (freq ,(20* log10 (abs(amp ))));
grid on;
title (' Amplitudengang  IIR  Tiefpass  ( Elliptic ) in dB ');
xlabel ('Frequency  (Hz)');
ylabel ('Magnitude  (dB)');
subplot (2 ,1 ,2);
plot (freq ,abs(amp ));
grid on;
title (' Amplitudengang  IIR  Tiefpass  ( Elliptic ) mit  absoluter   Skala ');
xlabel ('Frequency  (Hz)');
%% IIR LP filter ( elliptic ) with stages
% run code above first !
[sos , g] = tf2sos (b, a);
[ iir_count , iir_order ]= size (sos );
iir_order = iir_order /2 -1;
% distribute gain equally among stages
for(k=1: iir_count )
for(m=1: iir_order +1)
sos(k,m)= sos(k,m)* nthroot (g, iir_count );
end
end
num = sos (: ,1:3);
den = sos (: ,4:6);

[amp1 , f1] = freqz(num(1,:) ,[den(1,1) den(1,2:3)]);
[amp2 , f2] = freqz(num(2,:) ,[den(2,1) den(2,2:3)]);

figure (13);
subplot (2 ,1 ,1);
plot (freq ,( 20* log10 (abs( amp1 )) + 20* log10 (abs( amp2 )) ) );
grid on;
title (' Amplitudengang  IIR  Tiefpass  ( Elliptic ) in dB ( Kaskadierung )');
xlabel ('Frequency  (Hz)');
ylabel ('Magnitude  (dB)');
subplot (2 ,1 ,2);
plot (freq ,abs( amp1 .* amp2 ));
grid on;
title (' Amplitudengang  IIR  Tiefpass  ( Elliptic ) mit  absoluter   Skala  ( Kaskadierung )');
xlabel ('Frequency  (Hz)');
%% Modified LP Filter ( elliptic ) [ Attachment H]
num_modified = zeros (2 ,5);
den_modified = zeros (2 ,5);
for i= 1: iir_count ;
num_modified (i ,1) = num(i ,1);
num_modified (i ,3) = num(i ,2);
num_modified (i ,5) = num(i ,3);
den_modified (i ,1) = den(i ,1);
den_modified (i ,3) = den(i ,2);
den_modified (i ,5) = den(i ,3);
end
[amp1 , f1] = freqz(num(1,:) ,[den(1,1) den(1,2:3)]);
[amp2 , f2] = freqz(num(2,:) ,[den(2,1) den(2,2:3)]);
figure (99);
subplot (2 ,1 ,1);
plot (freq ,( 20* log10 (abs( amp1 )) + 20* log10 (abs( amp2 )) ) );
grid on;
title (' Amplitudengang   modifizierter  IIR  Tiefpass  ( Elliptic ) in dB ');
xlabel ('Frequency  (Hz)');
ylabel ('Magnitude  (dB)');
subplot (2 ,1 ,2);
plot (freq ,abs( amp1 .* amp2 ));
grid on;
title (' Amplitudengang   modifizierter  IIR  Tiefpass  ( Elliptic ) mit  absoluter   Skala ');
xlabel ('Frequency  (Hz)');
%% IIR LP filter ( chebychev )
fs =8000; % sample frequency
% define filter
Wp = 1950/( fs /2); % passband corner frequency
Ws = 3000/( fs /2); % stopband corner frequency
Rp =0.01; % passband ripple in dB
Rs =40; % stopbandripple in dB
% calculate minimum order n needed for required specification
[n,Wp] = cheb1ord (Wp ,Ws ,Rp ,Rs );
% design elliptic filter (in this case lowpass )
% returns numerator b and denumerator a of H(z)
[b,a] = cheby1 (n,Rp ,Wp );
% display frequency response of given digital filter
[amp , freq ] = freqz (b,a ,512 , fs );
figure (1);
subplot (2 ,1 ,1);
plot (freq ,(20* log10 (abs(amp ))));
grid on;
title (' Amplitudengang  IIR  Tiefpass  ( Chebychev ) in dB ');
xlabel ('Frequency  (Hz)');
ylabel ('Magnitude  (dB)');
subplot (2 ,1 ,2);
plot (freq ,abs(amp ));
grid on;
title (' Amplitudengang  IIR  Tiefpass  ( Chebychev ) mit  absoluter   Skala ');
xlabel ('Frequency  (Hz)');
%% IIR LP filter ( chebychev ) with stages
% run code above first !
[sos , g] = tf2sos (b, a);
[ iir_count , iir_order ]= size (sos );
iir_order = iir_order /2 -1;
% distribute gain equally among stages
for(k=1: iir_count )
for(m=1: iir_order +1)
sos(k,m)= sos(k,m)* nthroot (g, iir_count );
end
end
num = sos (: ,1:3);
den = sos (: ,4:6);
[amp1 , f1] = freqz(num(1,:) ,[den(1,1) den(1,2:3)]);
[amp2 , f2] = freqz(num(2,:) ,[den(2,1) den(2,2:3)]);
figure (13);
subplot (2 ,1 ,1);
plot (freq ,( 20* log10 (abs( amp1 )) + 20* log10 (abs( amp2 )) ) );
grid on;
title (' Amplitudengang  IIR  Tiefpass  ( Elliptic ) in dB ( Kaskadierung )');
xlabel ('Frequency  (Hz)');
ylabel ('Magnitude  (dB)');
subplot (2 ,1 ,2);
plot (freq ,abs( amp1 .* amp2 ));
grid on;
title (' Amplitudengang  IIR  Tiefpass  ( Elliptic ) mit  absoluter   Skala  ( Kaskadierung )');
xlabel ('Frequency  (Hz)');
%% IIR HP filter ( elliptic )
fs =8000; % sample frequency
% define filter
Wp = 2050/( fs /2); % passband corner frequency
Ws = 1000/( fs /2); % stopband corner frequency
Rp =0.01; % passband ripple in dB
Rs =40; % stopbandripple in dB
% calculate minimum order n needed for required specification
[n,Wp] = ellipord (Wp ,Ws ,Rp ,Rs );
% design elliptic filter (in this case lowpass )
% returns numerator b and denumerator a of H(z)
[b, a] = ellip (n,Rp ,Rs ,Wp ,'high');
% display frequency response of given digital filter
[amp , freq ] = freqz (b,a ,512 , fs );
figure (1);
subplot (2 ,1 ,1);
plot (freq ,(20* log10 (abs(amp ))));
grid on;
title (' Amplitudengang  IIR  Hochpass  ( Elliptic ) in dB ');
xlabel ('Frequency  (Hz)');
ylabel ('Magnitude  (dB)');
subplot (2 ,1 ,2);
plot (freq ,abs(amp ));
grid on;
title (' Amplitudengang  IIR  Hochpass  ( Elliptic ) mit  absoluter   Skala ');
xlabel ('Frequency  (Hz)');
%% IIR HP filter ( elliptic ) with stages
% run code above first !
[sos , g] = tf2sos (b, a);
[ iir_count , iir_order ]= size (sos );
iir_order = iir_order /2 -1;
% distribute gain equally among stages
for(k=1: iir_count )
for(m=1: iir_order +1)
sos(k,m)= sos(k,m)* nthroot (g, iir_count );
end
end
num = sos (: ,1:3);
den = sos (: ,4:6);
[amp1 , f1] = freqz(num(1,:) ,[den(1,1) den(1,2:3)]);
[amp2 , f2] = freqz(num(2,:) ,[den(2,1) den(2,2:3)]);
figure (13);
subplot (2 ,1 ,1);
plot (freq ,( 20* log10 (abs( amp1 )) + 20* log10 (abs( amp2 )) ) );
grid on;
title (' Amplitudengang  IIR  Tiefpass  ( Elliptic ) in dB ( Kaskadierung )');
xlabel ('Frequency  (Hz)');
ylabel ('Magnitude  (dB)');
subplot (2 ,1 ,2);
plot (freq ,abs( amp1 .* amp2 ));
grid on;
title (' Amplitudengang  IIR  Tiefpass  ( Elliptic ) mit  absoluter   Skala  ( Kaskadierung )');
xlabel ('Frequency  (Hz)');
%% simulation
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
[sos ,g] = tf2sos (b,a);
% filter with cascaded filter
y_n = x_n;
for i=1: size (sos ,1)
y_n = filter (sos(i ,1:3) , sos(i ,4:6) , y_n );
end
y_n = y_n*g;
% original filter to compare with cascaded filter
y_n2 = x_n;
y_n2 = filter (b,a, y_n2 );
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