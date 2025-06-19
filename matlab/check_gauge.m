clear
close all

%% filenames
rundir = '../run_flat_wavetank/_output';
list_files = dir(fullfile(rundir,'gauge0*.txt'));

k = 5;
file = fullfile(rundir,list_files(k).name);

dat = readmatrix(file,FileType="text",CommentStyle='#');

t = dat(:,2);
eta = dat(:,5);

fig = figure;
plot(t,eta,'-');
