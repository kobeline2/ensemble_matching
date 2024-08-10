%%% アンサンブル予測雨量のグラフの描画 %%%

%% パラメータの設定
% アンサンブル雨量のデータがあるフォルダ
ensFolder = '\\10.244.3.104\homes\アンサンブル予測\OutputRain\ensemble';
basin = 'miya'; % 流域
h = 72; % 対象期間(hours)
targetTime = '201710200900'; % 対象期間の開始年月日時
initTime = '201710180900'; % アンサンブルの初期時刻
mem = 1; % アンサンブルのメンバー

%% 雨量データの読み込み
filename = fullfile(ensFolder,basin,sprintf('%dhours',h),targetTime, ...
                    sprintf('%s_%s_%03d.dat',basin,initTime,mem));
rain = readmatrix(filename);

%% 年月日ベクトルの作成
% targetTimeから対象期間の開始月日を取得
dt = datetime(targetTime,'InputFormat','yyyyMMddHHmm','Format','MM/dd');
for i = 1:length(rain)/24
    dt(i+1) = dt(i) + 1;
end
dt = char(dt(2:end)); % 文字配列に変換

%% グラフの描画
figure('Position', [600 500 500 150])
bar(rain)
hold on
% 最初の3日間にハッチング
% fill([0,72,72,0],[0,0,50,50],[1 0.5 0.5],FaceAlpha=0.3,EdgeColor='none')
hold off
ylim([0 40])
ylabel('rain [mm/h]','FontSize',12)
if filename(end-10) == '9' % 初期時刻が09時の場合
    xticks(15.5:24:length(rain))
elseif filename(end-10) == '1' % 初期時刻が21時の場合
    xticks(3.5:24:length(rain))
end
xticklabels(dt)