%%% d4PDFをクラスタリングし，アメダスとアンサンブルをクラスターに振り分ける %%%
% 1 → 2 → 3-1 or 3-2 or 3-3 → 4 (→ 5 → 6 → 7-1 or 7-2 or 7-3) → 8 → 9 → 10 (→ 11)の順に実行する

%% 1.パラメータの設定
% 共通
basin = 'yahagi'; % 流域(矢作川'yahagi',三峰川'mibu')
h = 72; % 対象期間(hours)

% d4PDF関連(2.,3.,7.)
d4pdfFolder = append('\\10.244.3.104\homes\アンサンブル予測\outputRain\d4pdf\',basin,'\',num2str(h),'hours\'); % クラスタリングしたい雨量データがあるフォルダ
filename = '*.dat'; % 読み込みたい雨量データのファイル名 test:basin='yahagi',filename='*_28*.dat'
threshold = 0.8; % 不整合係数の閾値
numcl = 12; % 作成するクラスターの数(threshold or numcl のどちらか一方を設定)
col = 4; % 7-1. 7-2. 7-3.のグラフの列数

% アメダス,アンサンブル関連(9.,10.)
startY = 2020; % 対象期間の開始年
startM = 6; % 対象期間の開始月
startD = 28; % 対象期間の開始日
startH = 9; % 対象期間の開始時(9 or 21)
amedasFolder = append('\\10.244.3.104\homes\アンサンブル予測\outputRain\amedas\', ...
    basin,'\',num2str(h),'hours\'); % アメダス雨量のデータがあるフォルダ
ensFolder = append('\\10.244.3.104\homes\アンサンブル予測\outputRain\ensemble\',basin,'\',num2str(h),'hours\', ...
    num2str(startY),num2str(startM,'%02d'),num2str(startD,'%02d'),num2str(startH,'%02d'),'00\'); % アンサンブル雨量のデータがあるフォルダ

%% 2.d4PDF雨量データの読み込み
cd(d4pdfFolder)
list = dir(filename);
rain = zeros(length(list),h); % 配列の事前割り当て
for i = 1:length(list)
    rain(i,:) = readmatrix(list(i).name);
end

%% 3-1.k-means法
idx = kmeans(rain,numcl,'Start','sample'); % 作成するクラスターの数を指定

%% 3-2.ウォード法
euclid = pdist(rain); % オブジェクト間のユークリッド距離を計算
% squareform(d) % 距離ベクトルを行列に作り替える
link = linkage(euclid,"ward"); % 近接するオブジェクトのペアをリンク(ウォード法)

figure('Position',[500 200 900 500]) % 3列目が幅，4列目が高さ
dendrogram(link,length(list)) % ツリーをプロット

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

%% 6.idxを昇順にして，rainを並び替える(任意)
[idx,I] = sort(idx);
rain = rain(I,:);

%% 7-1.ハイエトグラフ描画(全部)
figure('Position',[500 200 1100 550]) % 3列目が幅，4列目が高さ
t = tiledlayout(length(list)/col,col,"TileSpacing","tight"); % グラフのレイアウトの作成
color = colororder("gem12"); % 12色まで対応
for i = 1:length(list)
    nexttile
    bar(rain(i,:),'FaceColor',color(mod(idx(i),size(color,1))+1,:)) % idxの値で色を分ける
    xlim([0 h])
    xticks(0:24:h)
    ylim([0 30])
    yticks(0:10:30)
    if i <= length(list)-col % 最下段以外
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

%% 7-2.ハイエトグラフ描画(各クラスター1つずつ)
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

%% 7-3.ハイエトグラフ描画(各クラスターの平均降雨波形)
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

%% 8.各クラスターの重心を計算
centRain = zeros(max(idx),size(rain,2)); % 配列の事前割り当て
for i = 1:max(idx)
    clusRain = rain(idx==i,:); % 同じクラスターの雨をまとめる
    centRain(i,:) = mean(clusRain,1); % 各クラスターの重心を求める
end

%% 9.アメダス雨量の読み込み + 分類 + Nash係数を計算
d = zeros(1,max(idx)); % 配列の事前割り当て
nash = zeros(1,max(idx)); % 配列の事前割り当て
amedasRain = readmatrix(append(amedasFolder,basin,'_', ...
    num2str(startY),num2str(startM,'%02d'),num2str(startD,'%02d'),num2str(startH,'%02d'),'00.dat')); % アメダス雨量の読み込み
for i = 1:max(idx)
    % (1)ユークリッド距離
    d(i) = norm(centRain(i,:)'-amedasRain); % d4PDFの各クラスターの重心とアメダスの間の距離を計算
    % (2)ウォード法
    % d(i) = sqrt((2*nnz(idx==i))/(1+nnz(idx==i)))*norm(centRain(i,:)'-amedasRain); % d4PDFの各クラスターとアメダスの間の距離をウォード法で計算
    % Nash係数
    bunsi = 0;
    bunbo = 0;
    for j = 1:h
        bunsi = bunsi + (amedasRain(j)-centRain(i,j))^2;
        bunbo = bunbo + (amedasRain(j)-mean(amedasRain))^2;
    end
    nash(i) = 1 - bunsi/bunbo; % Nash係数を計算
end
[mind,amedasIDX] = min(d); % アメダスが分類されたクラスター番号を取得

%% 10.アンサンブル予測雨量の読み込み + 分類
% 初期時刻を対象期間の開始時刻に設定
Y = startY;
M = startM;
D = startD;
H = startH;

ensIDX = zeros(1,51); % 配列の事前割り当て
numMem = zeros(max(idx),31-h/12); % 配列の事前割り当て

for initTimeNum = 1:31-h/12 % 初期時刻
    % 初期時刻の文字列の作成
    initTime = append(num2str(Y),num2str(M,'%02d'),num2str(D,'%02d'),num2str(H,'%02d'),'00');
    
    for mem = 1:51 % アンサンブル予測のメンバー(通常はmem = 1:51)        
        ensRain = readmatrix(append(ensFolder,basin,'_',initTime,num2str(mem,'_%03d'),'.dat')); % アンサンブル雨量の読み込み
        for i = 1:max(idx)
            % (1)ユークリッド距離
            d(i) = norm(centRain(i,:)'-ensRain); % d4PDFの各クラスターの重心とアンサンブルの間の距離を計算
            % (2)ウォード法
            % d(i) = sqrt((2*nnz(idx==i))/(1+nnz(idx==i)))*norm(centRain(i,:)'-ensRain); % d4PDFの各クラスターとアンサンブルの間の距離をウォード法で計算
        end
        [mind,ensIDX(mem)] = min(d); % アンサンブルが分類されたクラスター番号を取得
    end
    
    for i = 1:max(idx)
        numMem(i,32-h/12-initTimeNum) = nnz(ensIDX==i); % 各クラスターに分類されたメンバー数を格納
    end

    % 初期時刻の更新(-12h)
    H = H - 12;
    if H < 1
        H = 21;
        D = D - 1;
        if D < 1 % !!!1月=>12月と3月=>2月には対応していないので注意!!!
            M = M - 1;
            D = 31;
            if M==4 || M==6 || M==9 || M==11
                D = 30;
            end
        end
    end
end

%% 11.ヒートマップの作成
% 日時ベクトルの作成
dt = datetime(str2double(initTime(1:4)),str2double(initTime(5:6)), ...
    str2double(initTime(7:8)),str2double(initTime(9:10)),00,00,'Format','MM/dd HH');
for i = 1:31-h/12
    dt(i+1) = dt(i) + 1/2; % +12h
end
dt = char(dt(1:end-1));

% ヒートマップの作成(large)
figure('Position',[300 200 900 450]) % 3列目が幅，4列目が高さ
heat = heatmap(numMem,"Colormap",jet,"ColorLimits",[0 51]);
heat.XLabel = 'Initial Time';
heat.YLabel = 'Cluster Number';
heat.XDisplayLabels = dt;
heat.FontSize = 14; %8;

% ヒートマップの作成(small)
figure('Position',[1300 200 500 250]) % 3列目が幅，4列目が高さ
heat = heatmap(numMem,"Colormap",jet,"ColorLimits",[0 51]);
heat.XLabel = 'Initial Time';
heat.YLabel = 'Cluster Number';
heat.XDisplayLabels = dt;
heat.FontSize = 8;