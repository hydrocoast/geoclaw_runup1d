clear
close all

%% filenames
% rundir = '../run_flat_wavetank/_output';
rundir = '../run_slope50_wavetank/_output';
list_files = dir(fullfile(rundir,'fort.q*'));
nfile = size(list_files,1);

dx_true = 1.0;

%% parameter for gif
sizen = 256;
delaytime = 0.25;
[~,filename_gif] = fileparts(strrep(rundir,'/_output',''));
filename_gif = [filename_gif,'_surf.gif'];


fig = figure;
for k = 1:nfile
% for k = 1:1
    %% read header
    filename_q = fullfile(rundir,list_files(k).name);
    header = readmatrix(filename_q, FileType="text", Range=[3,1,5,1]);
    nx = header(1);
    xlow = header(2);
    dx = header(3);
    clear header
    x = linspace(xlow,xlow+dx_true*(nx-1),nx)';

    filename_t = strrep(filename_q,'.q0','.t0');
    t = readmatrix(filename_t, FileType="text", Range=[1,1,1,1]);


    %% read grid values
    dat = readmatrix(filename_q, FileType="text", NumHeaderLines=6);
    D = dat(:,1); % total depth
    dry = D<1e-3;
    eta = dat(:,3); % water surface
    h = D-eta; % bathymetry
    eta(dry) = NaN;
    clear dat

    %% plot
    clf(fig);
    tile = tiledlayout(2,1);

    % % water surface and bathymetry
    ax(1) = nexttile;
    plot(x,eta,'-',LineWidth=1); hold on
    plot(x,-h,'k-',LineWidth=1); hold on
    grid on
    ylim(ax(1),[-120,10]);

    % % water surface and bathymetry
    ax(2) = nexttile;
    plot(x,eta,'-',LineWidth=1); hold on
    grid on
    ylim(ax(2),[-1,3.0]);

    set(ax,FontName='Helvetica',FontSize=14);
    ytickformat(ax(2),'%0.1f');

    xlim(ax,[0,x(end)]);
    linkaxes(ax,'x');
    

    ax(1).XAxis.TickLabels = '';
    ylabel(ax(1),'Elevation (m)',FontName='Helvetica',FontSize=14);
    xlabel(ax(2),'Horizontal distance (m)',FontName='Helvetica',FontSize=14);
    
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
