clear
close all

% topofile = 'slope_test010.dat'; s = 1/10; % slope 1200 m
% topofile = 'slope_test015.dat'; s = 1/15; % slope 1800 m
% topofile = 'slope_test020.dat'; s = 1/20; % slope 2400 m
% topofile = 'slope_test025.dat'; s = 1/25; % slope 3000 m
% topofile = 'slope_test030.dat'; s = 1/30; % slope 3600 m
% topofile = 'slope_test040.dat'; s = 1/40; % slope 4800 m
% topofile = 'slope_test050.dat'; s = 1/50; % slope 6000 m
% topofile = 'slope_test060.dat'; s = 1/60; % slope 7200 m
% topofile = 'slope_test070.dat'; s = 1/70; % slope 8400 m
% topofile = 'slope_test080.dat'; s = 1/80; % slope 9600 m
% topofile = 'slope_test090.dat'; s = 1/90; % slope 10800 m
topofile = 'slope_test100.dat'; s = 1/100; % slope 12000 m
topodir = '../topo';

%% flat bottom
h0 = -100;
dx = 2.0;
length_flat = 10000;
x0 = 0.0;

x_flat = (x0:dx:length_flat+x0)';
nx_flat = length(x_flat);

%% slope
h_land = 20;
length_slope = (h_land-h0)/s;
x_slope = x_flat(end) + (dx:dx:length_slope)';
nx_slope = length(x_slope);

h_slope = h0 + s.*(x_slope-x_flat(end));

x_all = vertcat(x_flat,x_slope);
h_all = vertcat(h0*ones(nx_flat,1),h_slope);
nx_all = length(x_all);


%% plot
plot(x_all,h_all,'-');
axis tight

%% print
fid = fopen(topofile,"w");
    fprintf(fid,'%d\n',nx_all);
    for i = 1:nx_all
        fprintf(fid,'%10.3f %10.3f\n',[x_all(i),h_all(i)]);
    end
fclose(fid);

if ~isfolder(topodir); mkdir(topodir); end
movefile(topofile,topodir);

