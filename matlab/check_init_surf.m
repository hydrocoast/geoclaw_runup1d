clear
close all

ampl = 0.1;
x = 0.0:1.0:5000.0;
s = 0.005;
eta0 = ampl.*1./(cosh(s.*(x-1000)).^2);

plot(x,eta0,'-');








