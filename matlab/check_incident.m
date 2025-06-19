clear
close all

dt = 0.1;
t = 0:100;
s = 0.25;

plot(t,1./(cosh(s.*(t-20)).^2),'-');



