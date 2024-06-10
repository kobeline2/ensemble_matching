function out = main(pathConfig)
% MAIN - Main function of the clustering algorithm
%   This function is the main function of the clustering algorithm.
%   It reads the configuration file, reads the D4PDF data, clusters the data,
%   postprocesses the clustering results, and matches the cluster centroids
%   with AMeDAS data and ensemble data.
%
init
p = initializeConfig(pathConfig);
rain = readD4pdf(p);
idx = clusteringD4pdf(p, rain);
[idx, aveRain, nRainPerCluster, centRain] = postprocessClutering(p, rain, idx);
[mind, amedasIdx, nash] = matchingAmedas(p, centRain);
[nMember] = matchingEnsemble(p, centRain);

out = struct('idx', idx,...
             'aveRain', aveRain,...
             'nRainPerCluster', nRainPerCluster,...
             'mind', mind,...
             'amedasIdx', amedasIdx,...
             'nash', nash,...
             'nMember', nMember);
end