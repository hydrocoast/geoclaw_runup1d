clear
close all

%% filename
simdir{1,1} = '../run_slope50_wavetank/_output';
simdir{2,1} = '../run_slope50_wavetank_nd_nofriction/_output';
fgmaxtxt = 'fgmax.txt';

%% load
[xcell,topo,hmax1,smax1,hssmax1,etamax1,arrival_time1] = readfgmaxtxt(fullfile(simdir{1},fgmaxtxt));
[    ~,   ~,hmax2,smax2,hssmax2,etamax2,arrival_time2] = readfgmaxtxt(fullfile(simdir{2},fgmaxtxt));

[~,ind] = min(abs(topo));
x_topo0 = xcell(ind);

%% suppress to show the dry area
dry1 = hmax1<1e-6;
etamax(dry1) = NaN;
dry2 = hmax2<1e-6;
etamax(dry2) = NaN;

%% Green's law
h0 = abs(min(topo));
amp = 1.0; % max amplitude at t=0
hratio = h0./(-topo);
hratio(hratio<0.0|hratio>1000.0) = NaN;
etamax_gl = amp.*(hratio.^(0.25));

%% plot
fig = figure;
%% overall
ax = axes;
set(ax, FontName="Helvetica", FontSize=14);
plot(xcell, topo, 'k-', 'LineWidth', 1.5);
hold on;
lG = plot(xcell, etamax_gl, '-', 'LineWidth', 1.5, Color=[0.0,0.5,0.0,0.8]);
lA = plot(xcell, etamax1, '-', 'LineWidth', 2, Color=[0.0,0.0,1.0,0.7]);
lB = plot(xcell, etamax2, '-', 'LineWidth', 2, Color=[1.0,0.5,0.0,0.7]);
xlabel('{\it x} {\rm(m)}',FontName='Helvetica', FontSize=16);
ylabel('Elevation (m)',FontName='Helvetica',FontSize=16);
box on; grid on;
ylim(ax,[-3,7]);
set(ax, FontName="Helvetica", FontSize=14);
% legend([lA,lG],["Simulated","Green's law"],FontSize=16,FontName="Helvetica",Location="southwest");

%% runup
ax2 = axes(fig,"Position",[0.16,0.6,0.5,0.3]);
plot(xcell, topo, 'k-', 'LineWidth', 1.5); hold on
lG = plot(xcell, etamax_gl, '-', 'LineWidth', 1.5, Color=[0.0,0.5,0.0,0.8]);
lA = plot(xcell, etamax1, '-', 'LineWidth', 1.5, Color=[0.0,0.0,1.0,0.7]);
lB = plot(xcell, etamax2, '-', 'LineWidth', 1.5, Color=[1.0,0.5,0.0,0.7]);
xlim(ax2,[x_topo0-500,x_topo0+500]);
ylim(ax2,[0,6]);
grid on
set(ax2,FontName="Helvetica",FontSize=12,Box="on",GridColor="k");
legend(ax2,[lA,lB,lG],["Dispersive (SGN)","Non-dispersive","Green's law"],FontSize=12,FontName="Helvetica",Location="southeast");


function [xcell,topo,hmax,smax,hssmax,etamax,arrival_time] = readfgmaxtxt(filename)
    dat = readmatrix(filename,FileType="text",CommentStyle="#");

    xcell = dat(:, 1);
    topo = dat(:, 2);
    hmax = dat(:, 3);
    smax = dat(:, 4);
    hssmax = dat(:, 5);
    etamax = dat(:, 6);
    arrival_time = dat(:, 7);

    return

end


% dat = readmatrix(fullfile(simdir{1},fgmaxtxt),FileType="text",CommentStyle="#");
% 
% % # xcell, topo, hmax, smax, hssmax, etamax, arrival_time
% % Extract relevant columns from the loaded data
% xcell = dat(:, 1);
% topo = dat(:, 2);
% hmax = dat(:, 3);
% smax = dat(:, 4);
% hssmax = dat(:, 5);
% etamax = dat(:, 6);
% arrival_time = dat(:, 7);

