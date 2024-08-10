%%% アンサンブル予測のcsvファイルからh時間の流域平均雨量を抽出 %%%

% 用意する雨データ: yyyyMMddHHmm_mem.csv (アンサンブル降雨予測)
% 入手先: 一般財団法人 日本気象協会

%% パラメータの設定
basin = 'miya'; % 流域
h = 72; % 出力する雨量の期間(hours, 12<=h<=360 & mod(h,12)=0)
Y = 2017; % 対象期間の開始年
M = 10; % 対象期間の開始月
D = 20; % 対象期間の開始日
H = 9; % 対象期間の開始時(9 or 21)
% アンサンブルの格子の面積のデータがあるフォルダ
areaFolder = fullfile('\\10.244.3.104\homes\アンサンブル予測\QGIS',basin);
% アンサンブル雨量のデータがあるフォルダ
ensFolder = fullfile('\\10.244.3.104\homes\アンサンブル予測\ensemble',basin);
% 流域平均雨量を出力するフォルダ
outFolder = fullfile('\\10.244.3.104\homes\アンサンブル予測\OutputRain\ensemble', ...
                     basin,sprintf('%dhours',h), ...
                     sprintf('%04d%02d%02d%02d00',Y,M,D,H));

%% アンサンブル予測のグリッド数を取得
switch basin
    case 'yahagi' % 矢作川
        ROW = 17; % アンサンブル予測のグリッドの行数
        COL = 16; % アンサンブル予測のグリッドの列数
    case 'mibu' % 三峰川
        ROW = 9;
        COL = 8;
    case 'miya' % 宮川
        ROW = 11;
        COL = 14;
    case 'chikugo' % 筑後川
        ROW = 14;
        COL = 20;
end

%% 加重平均を計算するために，ティーセン分割後の各領域が流域と重なる面積を取得
areaCSV = readmatrix(fullfile(areaFolder, ...
                              sprintf('%s_area_per_enscell.csv',basin)), ...
                     "NumHeaderLines",1);
id = areaCSV(:,1); % 通し番号
area = areaCSV(:,2); % ティーセン分割によって作られた各メッシュが流域と重なる面積
[row,col] = ind2sub([ROW COL],1:ROW*COL); % 行番号と列番号の取得
row = row(id+1); % 通し番号に対応する行番号(pythonの通し番号が0スタートなので+1している)
col = col(id+1); % 通し番号に対応する列番号

%% 初期時刻毎，メンバー毎にh時間の流域平均雨量を算出してdatファイルに出力
for initTimeNum = 1:31-h/12 % 初期時刻
    % 初期時刻の文字列の作成
    initTime = sprintf('%04d%02d%02d%02d00',Y,M,D,H);
    
    for mem = 1:51 % アンサンブル予測のメンバー(通常はmem = 1:51)
        % 雨量の読み込み
        rainFile = fullfile(ensFolder,sprintf('%s_%02d.csv',initTime,mem));
        rain = readmatrix(rainFile,'NumHeaderLines',0,'Delimiter',',');
        idx = find(mod(1:length(rain),ROW+1) ~= 1); % 雨量が格納されている行番号を取得
        rain = rain(idx,1:COL); % 雨量のみの行列を作成
       
        % 指定した流域の雨を抽出して流域平均雨量を算出
        localRain = zeros(length(rain)/ROW,numel(id)); % 配列の事前割り当て
        for j = 1:length(rain)/ROW % csvに含まれる予測時間(通常は360時間)
            for i = 1:numel(id)
                localRain(j,i) = rain(ROW*(j-1)+row(i),col(i));
            end
        end
        localRain = localRain*area/sum(area); % 加重平均
    
        % h時間流域平均雨量をdatファイルに出力
        filename = fullfile(outFolder, ...
                            sprintf('%s_%s_%03d.dat',basin,initTime,mem));
        writematrix(localRain(12*(initTimeNum-1)+1:12*(initTimeNum-1)+h),filename)
    end
    
    % 初期時刻の更新(-12h)
    tmpDate = datetime(Y, M, D, H, 00, 00);
    tmpDate = tmpDate - hours(12);
    Y = tmpDate.Year;
    M = tmpDate.Month;
    D = tmpDate.Day;
    H = tmpDate.Hour;

end