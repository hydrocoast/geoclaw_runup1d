clear
close all

h0 = -100;
dx = 1.0;
x_flat = 5000;
x0 = 0.0;

% s = 0.1;
% h_land = 50;

X = (x0:dx:x_flat+x0)';
nx_flat = length(X);

topofile = 'flatbottom_5000m.dat';
topodir = '../topo';

fid = fopen(topofile,"w");
fprintf(fid,'%d\n',nx_flat);
    for i = 1:nx_flat
        fprintf(fid,'%10.3f %10.3f\n',[X(i),h0]);
    end
fclose(fid);


if ~isfolder(topodir); mkdir(topodir); end
movefile(topofile,topodir);

