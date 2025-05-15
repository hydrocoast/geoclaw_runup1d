clear
close all

%% filenames
rundir = '../testrun_0';
list_files = dir(fullfile(rundir,'_output','fort.q*'));
nfile = size(list_files,1);

[~,runname] = fileparts(rundir);
figdir = ['fig_',runname];
if ~isfolder(figdir); mkdir(figdir); end


fig = figure;

for k = 1:nfile

    %% read header
    filename_q = fullfile(list_files(k).folder, list_files(k).name);
    header = readmatrix(filename_q, FileType="text", Range=[3,1,5,1]);
    nx = header(1);
    xlow = header(2);
    dx = header(3);
    clear header
    x = linspace(xlow,xlow+dx*(nx-1),nx)';

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

    % % water surface and bathymetry
    ax(2) = nexttile;
    plot(x,eta,'-',LineWidth=1); hold on
    grid on

    set(ax,FontName='Helvetica',FontSize=14);
    % ytickformat(ax,'%0.1f');

    linkaxes(ax,'x');

    ax(1).XAxis.TickLabels = '';

    tile.Padding = 'compact';
    tile.TileSpacing = 'tight';


    %% add time information
    x0 = ax(1).XLim(1);
    y0 = ax(1).YLim(1);
    xrange = diff(ax(1).XLim);
    yrange = diff(ax(1).YLim);
    text(ax(1), x0+0.55*xrange, y0+0.95*yrange, sprintf('%0.1f s',t), FontName='Helvetica', FontSize=16, HorizontalAlignment='right', VerticalAlignment='top');

    %% export
    figname = [list_files(k).name,'.png'];
    exportgraphics(fig,figname,ContentType="image",Resolution=150);
    movefile(figname,figdir);

end
