function [jPCA_scores,Loads_jPC]=jPCA_for_Aplysia(filename,varargin)
%% jPCA_for_Aplysia performs jPCA in a segment of a recording
%
% DESCRIPTION:
%   This function computes jPCA (Jordan Principal Component Analysis)
%   on neural spike recordings from Aplysia. The method follows:
%   Churchland et al. (2012), designed to capture rotational dynamics
%   in population activity.
%
% USAGE:
%   [jPCA_scores, Loads_jPC] = jPCA_for_Aplysia(filename)
%   [jPCA_scores, Loads_jPC] = jPCA_for_Aplysia(filename, start_time)
%   [jPCA_scores, Loads_jPC] = jPCA_for_Aplysia(filename, start_time, end_time)
% 
% 
%
% INPUTS:
%   filename    : string (e.g.'Feb0416_1.mat')
%                 Path to .mat file containing:
%                 - spks: [neuron_id, spike_time (s)]
%                 - stim_time: stimulus time (string or numeric)
%
% OPTIONAL INPUTS:
%   start_time  : scalar (seconds)
%                 Time to start analysis. If not provided, defaults to
%                 ~10 seconds after stimulus onset.
%
%   end_time    : scalar (seconds)
%                 Time to end analysis. If not provided, defaults to
%                 the end of the recording.
%
% OUTPUTS:
%   jPCA_scores : [T x N] matrix. By default only the first 6 dimensions
%                 are used.
%                 Low-dimensional projections of neural activity onto
%                 jPCA axes (rotational components).
%
%   Loads_jPC   : [neurons x N] matrix
%                 jPCA loading vectors (mapping neurons to jPC space).
%
%
% PARAMETERS:
%   bint  : bin size in ms (default = 50 ms)
%   ndim  : number of PCA dimensions used for jPCA (default = 6)
%
%
% REFERENCE:
%   Churchland MM et al. (2012).
%   Neural population dynamics during reaching.
%   Nature.
%
%
% Andrea Colins Rodriguez
% 19/03/2025

start_time = nan; % default
end_time = nan; % default

if nargin == 2
    start_time = varargin{1}; % in s
elseif nargin == 3
    start_time = varargin{1}; % in s
    end_time = varargin{2}; % in s
elseif nargin > 4
    disp('JPCA_new can take upto 2 optional times. See documentation.')

end

% add scripts in all subfolders
pathjPCA = fileparts(which(mfilename));
addpath(genpath(pathjPCA))

%% 0. Define parameters

bint=50; %ms bins to format the data into. Here each bin of the total_matrix_1 corresponds to the number of spikes in a 50 ms bin
ndim = 6; % number of dimensions to create PCA to then do jPCA

% aux vars
toS = bint/1000;
toBins = 1000/bint;

%% 1. Load data

load(filename)
Nneurons = max(spks(:,1)); % number of neurons

% if start and end are not specified by the user analyse the entire
% recording

if isnan(start_time)
    start_time = regexp(stim_time, '\d+')*60+10;% in seconds
end

if isnan(end_time)
    end_time=floor(max(spks(:,2)));% in seconds
end

%% 2. Get firing rate

matrix = spikest2vector_AP(spks,start_time,end_time,bint);

%% 3. filter spikes
% by default, the spike trains are filter with a gaussian filter of sigma =
% median Inter Spike Interval

meanISI=median_ISI(spks,start_time);% in seconds
sig=round(meanISI*toBins);%in bins
[total_matrix_1,shiftbase]=filter_spikes(sig,matrix);

total_matrix_1=total_matrix_1'; % rows are times, columns are neurons

%% 4. jPCA
jPCA_params.params=false;
jPCA_params.numPCs = ndim;  % default anyway, but best to be specific
jPCA_params.suppressBWrosettes = true;  % these are useful sanity plots, but lets ignore them for now
jPCA_params.suppressHistograms = true;  % these are useful sanity plots, but lets ignore them for now
jPCA_params.suppressText=true;
jPCA_params.softenNorm=10;

endt = size(total_matrix_1,1);

xtime=(1:endt)*round(bint); % in ms so jPCA doesn´t complain about short derivatives

Data(1).A=total_matrix_1;
Data(1).times=xtime';
[scorestruct,summary] = jPCA_new(Data, xtime, jPCA_params);

% extracting projections
PCA_scores=scorestruct.tradPCAproj;% rows are times, columns are dimensions
jPCA_scores=scorestruct.proj;% rows are times, columns are dimensions

% key stats
Loads_jPC=summary.jPCs_highD;
%% 5. Visualise
%% 5.1 Raster
figure


subplot(2,2,1)
hold on
for iN=1:Nneurons
    plot(xtime/1000+start_time,matrix(iN,shiftbase+1:end)+iN)
end


%% 5.2 PCA

subplot(2,2,2)
title('PCA')
plot3(PCA_scores(:,1),PCA_scores(:,2),PCA_scores(:,3),'k')
xlabel('PC 1')
ylabel('PC 2')
zlabel('PC 3')

%% 5.3 jPCA
title('jPCA')
subplot(2,2,3)
plot3(jPCA_scores(:,1),jPCA_scores(:,2),jPCA_scores(:,3),'r')
xlabel('jPC 1')
ylabel('jPC 2')
zlabel('jPC 3')

%% 5.4 Var explained by both methods
subplot(2,2,4)
hold on
plot(1:ndim,cumsum(summary.varCaptEachPC),'k')
plot(1:ndim,cumsum(summary.varCaptEachJPC),'r')
xlabel('Number of dimension')
ylabel('Cumulative variance explained [%]')
legend('PCA','jPCA')
end