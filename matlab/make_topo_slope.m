clear
close all

topofile = 'slope_test50.dat';
topodir = '../topo';

%% flat bottom
h0 = -100;
dx = 2.0;
length_flat = 10000;
x0 = 0.0;

x_flat = (x0:dx:length_flat+x0)';
nx_flat = length(x_flat);

%% slope
s = 0.02; % slope
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


%% print
fid = fopen(topofile,"w");
    fprintf(fid,'%d\n',nx_all);
    for i = 1:nx_all
        fprintf(fid,'%10.3f %10.3f\n',[x_all(i),h_all(i)]);
    end
fclose(fid);

if ~isfolder(topodir); mkdir(topodir); end
movefile(topofile,topodir);

