# ensemble_matching

# parameter list
### 共通
1. basin: ryuiki name
1. h: duration, has to be 12*N
### d4PDF関連(2.,3.,7.)
1. d4pdfFolder: directory of d4pdf data (preprocessed), クラスタリングしたい雨量データがあるフォルダ
1. filename: 読み込みたい雨量データのファイル名 test:basin='yahagi',filename='*_28*.dat'
1. methodClustering: 'kmeans', 'ward1', or 'ward2'
1. threshold: 不整合係数の閾値
1. nCluster: 作成するクラスターの数(threshold or numcl のどちらか一方を設定)
1. col: 7-1. 7-2. 7-3.のグラフの列数
### アメダス, アンサンブル関連(9.,10.)
1. startY: 対象期間の開始年
1. startM: 対象期間の開始月
1. startD: 対象期間の開始日
1. startH: 対象期間の開始時(9 or 21)
1. amedasFolder: アメダス雨量のデータがあるフォルダ
1. ensFolder: アンサンブル雨量のデータがあるフォルダ


