clear
close all

%% filename
simdirA = '../run_slope50_wavetank/_output';
simdirB = '../run_slope50_wavetank_nd/_output';
fgmaxtxt = 'fgmax.txt';

%% load
datA = readmatrix(fullfile(simdirA,fgmaxtxt),FileType="text",CommentStyle="#");
datB = readmatrix(fullfile(simdirB,fgmaxtxt),FileType="text",CommentStyle="#");

% # xcell, topo, hmax, smax, hssmax, etamax, arrival_time
% Extract relevant columns from the loaded data
xcell = datA(:, 1);
topo = datA(:, 2);
hmaxA = datA(:, 3);
hmaxB = datB(:, 3);
etamaxA = datA(:, 6);
etamaxB = datB(:, 6);

[~,ind] = min(abs(topo));
x_topo0 = xcell(ind);

%% suppress to show the dry area
dryA = hmaxA<1e-6;
etamaxA(dryA) = NaN;
dryB = hmaxB<1e-6;
etamaxB(dryB) = NaN;

%% Green's law
h0 = abs(min(topo));
amp = 1.0; % max amplitude at t=0
hratio = h0./(-topo);
hratio(hratio<0.0|hratio>1000.0) = NaN;
etamax_gl = amp.*(hratio.^(0.25));

%%  plot
fig = figure;

%% overall
ax = axes;
lt = plot(xcell, topo, 'k-', 'LineWidth', 1.5); hold on
lg = plot(xcell, etamax_gl, '-', 'LineWidth', 1.5, Color=[0.0,0.5,0.0,0.8]);
lA = plot(xcell, etamaxA, '-', 'LineWidth', 1.5, Color=[0.4,0.4,0.0,0.8]);
lB = plot(xcell, etamaxB, '-', 'LineWidth', 1.5, Color=[0.4,0.0,0.4,0.8]);
xlabel('{\it x} {\rm(m)}',FontName='Helvetica', FontSize=16);
ylabel('Elevation (m)',FontName='Helvetica',FontSize=16);
box on; grid on;
ylim(ax,[-3,7]);
set(ax, FontName="Helvetica", FontSize=14);

%% runup
ax2 = axes(fig,"Position",[0.16,0.7,0.5,0.2]);
plot(xcell, topo, 'k-', 'LineWidth', 1.5); hold on
plot(xcell, etamax_gl, '-', 'LineWidth', 1.5, Color=[0.0,0.5,0.0,0.8]);
plot(xcell, etamaxA, '-', 'LineWidth', 1.5, Color=[0.4,0.4,0.0,0.8]);
plot(xcell, etamaxB, '-', 'LineWidth', 1.5, Color=[0.4,0.0,0.4,0.8]);
xlim(ax2,[x_topo0-500,x_topo0+500]);
ylim(ax2,[0,6]);
grid on
set(ax2,FontName="Helvetica",FontSize=12,Box="on",GridColor="k");

