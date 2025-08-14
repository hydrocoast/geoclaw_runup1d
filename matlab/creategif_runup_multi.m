clear
close all

%% filenames
% -------------------------------------------------------------
rundir{1,1} = '../run_slope50_wavetank/_output';
rundir{2,1} = '../run_slope50_wavetank_nd_nofriction/_output';
filename_gif = 'comparison_runup_slope50.gif';
% filename_gif = 'test.gif';
dx_true = 1.0;
% ------------------------------------------------------------

%% check the number of files
list_files = dir(fullfile(rundir{1},'fort.q*'));
nfile = size(list_files,1);
list_files_check = dir(fullfile(rundir{2},'fort.q*'));
if nfile ~= size(list_files_check,1)
    error('Inconsistent number of output files: fort.q*');
end

%% parameter for gif
sizen = 256;
delaytime = 0.20;


CG = [0.0,0.5,0.0,0.8];
C1 = [0.0,0.0,1.0,0.7];
C2 = [1.0,0.5,0.0,0.7];


%% read and plot
fig = figure;
for k = 1:nfile
% for k = 1:1
    %% read header
    filename_q{1,1} = fullfile(rundir{1},list_files(k).name);
    filename_q{2,1} = fullfile(rundir{2},list_files(k).name);    

    header = readmatrix(filename_q{1}, FileType="text", Range=[3,1,5,1]);
    nx = header(1);
    xlow = header(2);
    dx = header(3);
    clear header
    x = linspace(xlow,xlow+dx_true*(nx-1),nx)';

    filename_t = strrep(filename_q{1},'.q0','.t0');
    t = readmatrix(filename_t, FileType="text", Range=[1,1,1,1]);

    %% read grid values
    [~,eta1,h,dry1] = readfortq1d(filename_q{1});
    [~,eta2,~,dry2] = readfortq1d(filename_q{2});

    %% Green's law
    h0 = abs(max(h));
    amp = 1.0; % max amplitude at t=0
    hratio = h0./h;
    hratio(hratio<0.0|hratio>1000.0) = NaN;
    etamax_gl = amp.*(hratio.^(0.25));

    %% plot
    clf(fig);
    tile = tiledlayout(2,1);

    % % water surface and bathymetry
    ax(1) = nexttile;
    l1 = plot(x,eta1,'-',LineWidth=1,Color=C1); hold on
    l2 = plot(x,eta2,'--',LineWidth=1,Color=C2); hold on
    plot(x,-h,'k-',LineWidth=1); hold on
    grid on
    ylim(ax(1),[-120,10]);

    % % water surface and bathymetry
    ax(2) = nexttile;
    % lG = plot(x,etamax_gl,'-',LineWidth=1,Color=CG); hold on
    l1 = plot(x,eta1,'-',LineWidth=2,Color=C1); hold on
    l2 = plot(x,eta2,'--',LineWidth=2,Color=C2); hold on
    plot(x,-h,'k-',LineWidth=1); hold on
    grid on
    ylim(ax(2),[-1,3.0]);

    set(ax,FontName='Helvetica',FontSize=14);
    ytickformat(ax(2),'%0.1f');

    xlim(ax,[0,x(end)]);
    linkaxes(ax,'x');
    
    ax(1).XAxis.TickLabels = '';
    ylabel(ax(1),'Elevation (m)',FontName='Helvetica',FontSize=14);
    xlabel(ax(2),'Horizontal distance (m)',FontName='Helvetica',FontSize=14);

    legend(ax(1),[l1,l2,lG],["Dispersive (SGN)","Non-dispersive","Green's law"],FontSize=16,FontName="Helvetica",Location="southeast");
    % legend(ax(1),[l1,l2],["Dispersive","Non-dispersive"],FontSize=16,FontName="Helvetica",Location="southeast");

    
    tile.Padding = 'compact';
    tile.TileSpacing = 'tight';



    %% add time information
    x0 = ax(1).XLim(1);
    y0 = ax(1).YLim(1);
    xrange = diff(ax(1).XLim);
    yrange = diff(ax(1).YLim);
    text(ax(1), x0+0.05*xrange, y0+0.85*yrange, sprintf('%0.1f s',t), FontName='Helvetica', FontSize=16, HorizontalAlignment='left', VerticalAlignment='middle');
    x0 = ax(2).XLim(1);
    y0 = ax(2).YLim(1);
    xrange = diff(ax(2).XLim);
    yrange = diff(ax(2).YLim);
    text(ax(2), x0+0.05*xrange, y0+0.85*yrange, sprintf('%0.1f s',t), FontName='Helvetica', FontSize=16, HorizontalAlignment='left', VerticalAlignment='middle');

    drawnow;

    %% create gif
    frame = getframe(fig);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,sizen);
    % Write to the GIF File
    if k == 1
        imwrite(imind,cm,filename_gif,'gif', 'Loopcount',inf,'DelayTime',delaytime);
    else
        imwrite(imind,cm,filename_gif,'gif','WriteMode','append','DelayTime',delaytime);
    end    

end


function [D,eta,h,dry] = readfortq1d(filename)
    dat = readmatrix(filename, FileType="text", NumHeaderLines=6);
    D = dat(:,1); % total depth
    dry = D<1e-3;
    eta = dat(:,3); % water surface
    h = D-eta; % bathymetry
    eta(dry) = NaN;
    return
end