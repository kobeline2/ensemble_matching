%%% アンサンブル予測雨量51メンバー+アメダス観測雨量のグラフの描画 %%%

%% パラメータの設定
basin = 'miya'; % 流域
h = 72; % 対象期間の長さ(hour)
targetTime = '201710200900'; % 対象期間の開始年月日時
initTime = '201710150900'; % アンサンブルの初期時刻
Y = 2017; % 対象期間の開始年
M = 10; % 対象期間の開始月
D = 20; % 対象期間の開始日
H = 9; % 対象期間の開始時(9 or 21)
% アンサンブル雨量のデータがあるフォルダ
ensFolder = fullfile('\\10.244.3.104\homes\アンサンブル予測\OutputRain\ensemble', ...
                    basin,sprintf('%dhours',h),targetTime);
% アメダス雨量のファイル
amedasFile = fullfile('\\10.244.3.104\homes\アンサンブル予測\OutputRain\amedas', ...
                      basin,sprintf('%dhours',h), ...
                      sprintf('%s_%s.dat',basin,targetTime));

%% アンサンブル雨量データの読み込み
ensemble = zeros(h,51);
for mem = 1:51
    ensemble(:,mem) = readmatrix(fullfile(ensFolder, ...
                                          sprintf('%s_%s_%03d.dat', ...
                                                  basin,initTime,mem)));
end

%% アメダス雨量データの読み込み
amedas = readmatrix(amedasFile);

%% 年月日ベクトルの作成
dt = datetime(targetTime,'InputFormat','yyyyMMddHHmm','Format','MM/dd');
for i = 1:h/24
    dt(i+1) = dt(i) + 1;
end
dt = char(dt(2:end)); % 文字配列に変換

%% グラフの描画
figure('Position', [600 500 600 400])
p = plot(ensemble);
hold on
b = bar(amedas,'FaceColor',[0 0.4470 0.7410],'FaceAlpha',.7);
hold off
ylim([0 50])
yticks(0:10:50)
ylabel('rain [mm/h]','FontSize',12)
if H == 9 % 初期時刻が09時の場合
    xticks(15.5:24:h)
elseif H == 21 % 初期時刻が21時の場合
    xticks(3.5:24:h)
end
xticklabels(dt)
legend([p(1),b],"ensemble","amedas",Location="northwest")
fontsize(16,"points")