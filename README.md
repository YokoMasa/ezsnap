# ezsnap

サーバ構築などをしている時に設定ファイルを少し書き換えたい時があります。その時に編集前の状態をとっておくために「xxxx.bk」や「xxxx.20220207」みたいな形でバックアップを取った経験はないでしょうか？

またそういったバックアップファイルがいくつも存在していて、どれがどの断面のファイルなのか、消してはダメなのかと悩んだことはないでしょうか？

そのような課題を解決するために、コメント付きで簡単にファイルの断面管理ができるシェルスクリプトを作りました。

## 使用方法

```shell
$ echo "hello ver.1" > hello.txt
$ cat hello.txt
hello ver.1
$
$ # スナップショット作成
$ ./ezsnap.sh snap hello.txt Initial snapshot
Snap successful. ID: 1
$
$ # スナップショット一覧表示
$ ./ezsnap.sh list
ID      Timestamp       File path       Comment
1       2022-02-07T06:33:16+00:00       /home/yokomasa/hello.txt         Initial snapshot
$
$ # hello.txtの内容を編集
$ echo "hello ver.2" > hello.txt
$ cat hello.txt
hello ver.2
$
$ # スナップショット取得時の状態に戻す
$ ./ezsnap.sh restore 1 hello.txt
Restore successful. ID: 1
$ cat hello.txt
hello ver.1
$
$ # スナップショット削除
$ ./ezsnap.sh delete 1
Delete successful. ID: 1
$
$ ./ezsnap.sh list
ID      Timestamp       File path       Comment
$
```

## コマンド一覧

- スナップショット作成
  ./eznap.sh snap ${対象ファイルパス} ${コメント}
- スナップショット一覧表示
  ./ezsnap.sh list
- スナップショットリストア
  ./ezsnap.sh restore ${スナップショットID} ${リストア先ファイルパス}
  ※既存ファイルがある場合上書きしますのでご注意ください。
- スナップショット削除
  ./ezsnap.sh delete ${スナップショットID}

