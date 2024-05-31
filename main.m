function out = main(pathConfig)
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