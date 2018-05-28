# 課題自動チェックプログラム

# 使い方
## 実行チェックの流れ

1. 実行作業用のディレクトリを用意（今回は`work_dir/`がある）
2. 提出された課題ディレクトリ（`第n回 提出課題 .../`）をダウンロードして、このリポジトリと同じディレクトリに移動もしくはコピー
3. 自動コンパイルプログラムの実行
```
$ ruby lib/auto_cheak.rb [課題ディレクトリ名]
```
4. 実行チェックに必要なファイルとディレクトリを`work_dir`の中にあるそれぞれのディレクトリにコピーする
```
$ ruby lib/copy_to_workdir [コピーしたいパス1] [コピーしたいパス2] ...
```

5. `work_dir/`に生成された実行ファイルで実行チェックをする

## クリーン
課題ディレクトリと、生成した実行用のディレクトリは
```
$ rake clean
```
で削除できる

# プログラムの処理
* zipの解凍
* .cファイルのコンパイル
* 実行ファイルを実行作業用のディレクトリにコピー
