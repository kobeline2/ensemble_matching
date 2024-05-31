%%% d4PDFをクラスタリングする %%%
% 1 → 2 → 3-1 or 3-2 or 3-3 → 4 → 5 → 6-1 or 6-2 の順に実行する

%% 1.パラメータの設定
basin = ["mibu" "yahagi"]; % 流域
h = 72; % 対象期間(hours)
rank = 3; % 年何位までの雨量を用いるか(1~5)
filename = '*.dat'; % 読み込みたい雨量データのファイル名 test:basin='yahagi',filename='*_28*.dat'
d4pdfFolder = '\\10.244.3.104\homes\アンサンブル予測\outputRain\d4pdf\'; % クラスタリングしたい雨量データがあるフォルダ
threshold = 0.8; % 不整合係数の閾値
numcl = 12; % 作成するクラスターの数(threshold or numcl のどちらか一方を設定)
col = 4; % 7-1. 7-2. 7-3.のグラフの列数

%% 2.d4PDF雨量データの読み込み
cd(d4pdfFolder)
rain = [];
for i = 1:length(basin)
    for j = 1:rank
        list = dir(append(basin(i),'\',num2str(h),'hours\',num2str(j),'\',filename)); % '流域\時間\順位\ファイル名'
        rain2 = zeros(length(list),h); % 配列の事前割り当て
        for k = 1:length(list)
            rain2(k,:) = readmatrix(append(list(k).folder,'\',list(k).name));
        end
        rain = [rain;rain2];
    end
end

%% 3-1.k-means法
idx = kmeans(rain,numcl,'Start','sample'); % 作成するクラスターの数を指定

%% 3-2.ウォード法
euclid = pdist(rain); % オブジェクト間のユークリッド距離を計算
% squareform(d) % 距離ベクトルを行列に作り替える
link = linkage(euclid,"ward"); % 近接するオブジェクトのペアをリンク(ウォード法)

figure('Position',[500 200 900 500]) % 3列目が幅，4列目が高さ
dendrogram(link,size(rain,1)) % ツリーをプロット

cop = cophenet(link,euclid); % コーフェン相関係数を計算(1に近いほど◎)
inco = inconsistent(link); % 不整合係数を計算
% idx = cluster(link,"cutoff",threshold); % 不整合係数の閾値を指定してクラスターを作成
idx = cluster(link,"maxclust",numcl); % 作成するクラスターの数を指定

%% 3-3.ウォード法(別法)
% idx = clusterdata(rain,'Linkage','ward','Cutoff',threshold); % 不整合係数の閾値を指定してクラスターを作成
idx = clusterdata(rain,'Linkage','ward','MaxClust',numcl); % 作成するクラスターの数を指定

%% 4.各クラスターの平均総雨量を計算して，少ない順にクラスター番号を再度割り振る
aveRain = zeros(1,max(idx)); % 配列の事前割り当て
for i = 1:max(idx)
    clusRain = rain(idx==i,:); % 同じクラスターの雨をまとめる
    totalRain = sum(clusRain,2); % h時間の総雨量を計算
    aveRain(i) = mean(totalRain,1); % h時間総雨量のクラスター平均を計算
end
[aveRain,I] = sort(aveRain); % h時間総雨量の平均値が小さい順に並び替え
for i = 1:max(idx)
    idx(idx==I(i)) = i+length(idx); % 平均値に応じてidxを置換(最小idx=1)
end
idx = idx-length(idx); % 2行前で加えたlength(idx)を引く

%% 5.各クラスターに分類されたハイエトグラフの個数を取得(任意)
n = zeros(1,max(idx)); % 配列の事前割り当て
for i = 1:max(idx)
    n(i) = nnz(idx==i);
end

%% 6-1.ハイエトグラフ描画(各クラスター1つずつ)
figure('Position',[500 200 1000 300]) % 3列目が幅，4列目が高さ
t = tiledlayout(max(idx)/col,col,"TileSpacing","tight"); % グラフのレイアウトの作成
color = colororder("gem12"); % 12色まで対応
for i = 1:max(idx)
    nexttile
    clusRain = rain(idx==i,:); % 同じクラスターの雨をまとめる
    bar(clusRain(2,:),'FaceColor',color(mod(i,size(color,1))+1,:)) % idxの値で色を分ける
    %            ↑この値でサンプルを変更できる(1,2,10,endなど)
    xlim([0 h])
    xticks(0:24:h)
    ylim([0 30])
    yticks(0:10:30)
    if i <= max(idx)-col % 最下段以外
        ax = gca;
        ax.XTickLabel = cell(size(ax.XTickLabel)); % x軸の数値を削除
    end
    if mod(i,col) ~= 1 % 1列目以外
        ax = gca;
        ax.YTickLabel = cell(size(ax.YTickLabel)); % y軸の数値を削除
    end
end
fontsize(14,"points")
xlabel(t,'time [hour]','Fontsize',18)
ylabel(t,'rain [mm/h]','Fontsize',18)

%% 6-2.ハイエトグラフ描画(各クラスターの平均降雨波形)
figure('Position',[500 200 1000 300]) % 3列目が幅，4列目が高さ
t = tiledlayout(max(idx)/col,col,"TileSpacing","tight"); % グラフのレイアウトの作成
color = colororder("gem12"); % 12色まで対応
centRain = zeros(max(idx),size(rain,2)); % 配列の事前割り当て
for i = 1:max(idx)
    nexttile
    clusRain = rain(idx==i,:); % 同じクラスターの雨をまとめる
    centRain(i,:) = mean(clusRain,1); % 各クラスターの重心を求める
    bar(centRain(i,:),'FaceColor',color(mod(i,size(color,1))+1,:)) % idxの値で色を分ける
    %            ↑この値でサンプルを変更できる(1,2,10,endなど)
    xlim([0 h])
    xticks(0:24:h)
    ylim([0 30])
    yticks(0:10:30)
    if i <= max(idx)-col % 最下段以外
        ax = gca;
        ax.XTickLabel = cell(size(ax.XTickLabel)); % x軸の数値を削除
    end
    if mod(i,col) ~= 1 % 1列目以外
        ax = gca;
        ax.YTickLabel = cell(size(ax.YTickLabel)); % y軸の数値を削除
    end
end
fontsize(14,"points")
xlabel(t,'time [hour]','Fontsize',18)
ylabel(t,'rain [mm/h]','Fontsize',18)