function Comparing_jPCAs
%% Comparing_jPCAs perform jPCA in segments of the chosen recording 
%% and compares the participation of the neurons in the rotational 
%% dynamics across segments
%
% filename = string containing the name of the file
% 
% segments = (Nx2 matrix) every row defines a new segment in which the first and second column are the start 
% and end time respectively 
% values are in seconds from th start of the recording 
% the example below analyses two segments of the file Feb0416_1.mat: 
% segment 1: between 90 and 250 s 
% segment 2: between 300 and 900 s
%
% Andrea Colins Rodriguez
% 22/03/2026

filename = 'Feb0416_1.mat';

% Define as many segments as you want (Nx2 matrix)
segments = [
    90,250;
    300,900;
    % add more rows here
];

ndim = 2; % number of dimensions of jPCA to consider participation. Default =2

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Analyses
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nSegments = size(segments,1);
jPCA_scores = cell(nSegments,1);
Loads_jPC   = cell(nSegments,1);
Var_exp_jpc = cell(nSegments,1);
Participation = cell(nSegments,1);
NormPar = cell(nSegments,1);

for i = 1:nSegments
    [jPCA_scores{i}, Loads_jPC{i}, Var_exp_jpc{i}] = ...
        jPCA_for_Aplysia(filename, segments(i,1), segments(i,2));

    % Compute participation
    Participation{i} = sum(abs(Loads_jPC{i}(:,1:ndim)) .* ...
                          Var_exp_jpc{i}(1:ndim), 2);

    % Normalize
    NormPar{i} = Normalise(Participation{i});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plotting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure

%% (1) Variance explained
subplot(2,2,1)
varExplained = zeros(1,nSegments);
for i = 1:nSegments
    varExplained(i) = sum(Var_exp_jpc{i}(1:ndim));
end
bar(1:nSegments, varExplained)
box off
xlabel('Segments')
ylabel(['Variance explained by first ' num2str(ndim) ' jPCs'])

%% (2) Participation curves
subplot(2,2,2)
hold on
for i = 1:nSegments
    plot(NormPar{i})
end
xlabel('Neuron number')
ylabel(['Participation in first ' num2str(ndim) ' jPCs'])
legend(arrayfun(@(x) ['Segment ' num2str(x)], 1:nSegments, 'UniformOutput', false))
box off

%% (3) Pairwise scatter vs first segment (reference)
subplot(2,2,3)
hold on
for i = 2:nSegments
    scatter(NormPar{1}, NormPar{i})
end
plot([0,1],[0,1],'Color',[0.5 0.5 0.5]) % reference

xlim([0,1])
ylim([0,1])
xlabel('Participation segment 1')
ylabel('Participation other segments')
axis square
box off

end

function NormPar = Normalise(Participation)
Participation = Participation - min(Participation);
NormPar = Participation ./ max(Participation);
end