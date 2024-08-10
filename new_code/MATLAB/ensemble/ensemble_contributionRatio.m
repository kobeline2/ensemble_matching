%%% アンサンブル予測のcsvファイルからh時間のsubbasin平均雨量を抽出 %%%
%%% subbasinの寄与率を計算 %%%

%% パラメータの設定
basin = 'miya'; % 流域
h = 72; % 出力する雨量の期間(hours, 12<=h<=360 & mod(h,12)=0)
startY = 2023; % 対象期間の開始年
startM = 6; % 対象期間の開始月
startD = 1; % 対象期間の開始日
startH = 9; % 対象期間の開始時(9 or 21)
% アンサンブルの格子の面積のデータがあるフォルダ
ensAreaFolder = fullfile('\\10.244.3.104\homes\アンサンブル予測\QGIS\',basin);
% subbasinの面積のデータがあるフォルダ
subbasinAreaFolder = fullfile('\\10.244.3.104\homes\アンサンブル予測\QGIS\',basin);
% アンサンブル雨量のデータがあるフォルダ
ensRainFolder = fullfile('\\10.244.3.104\homes\アンサンブル予測\ensemble\',basin);
% 寄与率を出力するファイル
outFile = fullfile('\\10.244.3.104\homes\アンサンブル予測\contributionRatio\ensemble\', ...
                   basin,sprintf('%dhours',h), ...
                   sprintf('%s_%04d%02d%02d%02d00.mat', ...
                           basin,startY,startM,startD,startH));

%% 寄与率を計算するために，subbasinの面積を取得
subbasinArea = readmatrix(fullfile(subbasinAreaFolder, ...
                                   sprintf('%s_subbasin.dat',basin)), ...
                          "NumHeaderLines",0);
nSubbasin = length(subbasinArea); % subbasinの数

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
[row,col] = ind2sub([ROW COL],1:ROW*COL); % 行番号と列番号の取得
% subbasin
subID = cell(1,nSubbasin); % 通し番号
ensSubArea = cell(1,nSubbasin); % ティーセン分割によって作られた各領域が流域と重なる面積
subRow = cell(1,nSubbasin); % 通し番号に対応する行番号
subCol = cell(1,nSubbasin); % 通し番号に対応する列番号
for i = 1:nSubbasin
    ensSubAreaCSV = readmatrix(fullfile(ensAreaFolder, ...
                                        sprintf('%s%d_area_per_enscell.csv', ...
                                                basin,i)), ...
                               "NumHeaderLines",1);
    subID{i} = ensSubAreaCSV(:,1);
    ensSubArea{i} = ensSubAreaCSV(:,2);
    subRow{i} = row(subID{i}+1); % 通し番号に対応する行番号(pythonの通し番号が0スタートなので+1している)
    subCol{i} = col(subID{i}+1); % 通し番号に対応する列番号
end

%% 雨量の読み込み => 寄与率の計算
% 初期時刻を対象期間の開始時刻に設定
Y = startY;
M = startM;
D = startD;
H = startH;
tmpDate = datetime(Y, M, D, H, 00, 00);

% 寄与率
ensX = zeros((31-h/12)*51,nSubbasin);
% subbasinの総雨量
subbasinTotalRain = zeros((31-h/12)*51,nSubbasin);

% 初期時刻毎，メンバー毎にh時間のsubbasin平均雨量を算出
for initTimeNum = 1:31-h/12 % 初期時刻
    % 初期時刻の文字列の作成
    initTime = sprintf('%04d%02d%02d%02d00', Y, M, D, H);    
    
    for mem = 1:51 % アンサンブル予測のメンバー(通常はmem = 1:51)
        % 雨量の読み込み
        rainFile = fullfile(ensRainFolder,sprintf('%s_%02d.csv',initTime,mem));
        rain = readmatrix(rainFile,'NumHeaderLines',0,'Delimiter',',');
        idx = find(mod(1:length(rain),ROW+1) ~= 1); % 雨量が格納されている行番号を取得
        rain = rain(idx,1:COL); % 雨量のみの行列を作成

        subbasinRain = cell(1,nSubbasin); % subbasinの1時間ごとの平均雨量
        for k = 1:nSubbasin
            for j = 1:length(rain)/ROW % csvに含まれる予測時間(通常は360時間)
                for i = 1:numel(subID{k})
                    subbasinRain{k}(j,i) = rain(ROW*(j-1)+subRow{k}(i),subCol{k}(i));
                end
            end
            % 加重平均
            subbasinRain{k} = subbasinRain{k}*ensSubArea{k}/sum(ensSubArea{k});
            % 360時間雨量→h時間雨量
            subbasinRain{k} = subbasinRain{k}(12*(initTimeNum-1)+1:12*(initTimeNum-1)+h);
        end

        % 寄与率を計算
        den = 0; % 寄与率の分母
        for i = 1:nSubbasin
            den = den + sum(subbasinRain{i})*subbasinArea(i);
        end        
        for i = 1:nSubbasin
            ensX((initTimeNum-1)*51+mem,i)...
                = sum(subbasinRain{i})*subbasinArea(i)/den;
            subbasinTotalRain((initTimeNum-1)*51+mem,i)...
                = sum(subbasinRain{i});
        end
    end
    
    % 初期時刻の更新(-12h)
    tmpDate = tmpDate - hours(12);
    Y = tmpDate.Year;
    M = tmpDate.Month;
    D = tmpDate.Day;
    H = tmpDate.Hour;
end

%% 寄与率をmatファイルに保存
save(outFile,"ensX");