function [idx, aveRain, nRainPerCluster, centRain] = postprocessClutering(p, rain, idx)


% 4.各クラスターの平均総雨量を計算して，少ない順にクラスター番号を再度割り振る
aveRain = zeros(1, p.nCluster); 
for i = 1:p.nCluster
    % 各クラスタに属する降雨群のクラスター内平均を計算
    aveRain(i) = mean(sum(rain(idx==i, :), 2));
end
[aveRain, I] = sort(aveRain, 'ascend');
% 平均値に応じてidxを置換(最小idx=1)
for i = 1:p.nCluster
    idx(idx==I(i)) = i+length(idx); 
end
idx = idx-length(idx);

% 5.各クラスターに分類された降雨の個数を取得(任意)
nRainPerCluster = zeros(1, p.nCluster); 
for i = 1:p.nCluster
    nRainPerCluster(i) = nnz(idx==i);
end


% 8.各クラスターの重心を計算
centRain = zeros(p.nCluster, size(rain, 2)); % 配列の事前割り当て
for i = 1:p.nCluster
    clusRain = rain(idx==i, :); % 同じクラスターの雨をまとめる
    centRain(i,:) = mean(clusRain, 1); % 各クラスターの重心を求める
end

end