function idx = clusteringD4pdf(p, rain)

% clustering
switch p.methodClustering
    case 'kmeans'
        % 作成するクラスターの数を指定
        idx = kmeans(rain, p.nCluster, 'Start', 'sample'); 
    case 'ward1'
        % オブジェクト間のユークリッド距離を計算
        euclid = pdist(rain);
        % 近接するオブジェクトのペアをリンク(ウォード法)
        link = linkage(euclid, "ward"); 
        % ツリーをプロット
        figure('Position', [500 200 900 500]) % 3列目が幅，4列目が高さ
        dendrogram(link, length(list)) 
        
        fprintf('the inconsistency coefficient is %d', inconsistent(link))
        % 不整合係数の閾値を指定してクラスターを作成
        % idx = cluster(link,"cutoff",threshold); 
        % 作成するクラスターの数を指定
        idx = cluster(link, "maxclust", p.nCluster); % 作成するクラスターの数を指定
    case 'ward2'
        % 不整合係数の閾値を指定してクラスターを作成
        % idx = clusterdata(rain,'Linkage','ward','Cutoff',threshold); 
        % 作成するクラスターの数を指定
        idx = clusterdata(rain, 'Linkage', 'ward', 'MaxClust', p.nCluster); 
end

end