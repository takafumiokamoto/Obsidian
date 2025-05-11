# memo

## dockerコンテナ内でpodmanを使う

dockerはbuild, run時にセキュリティのため一部特権を制限している。
dockerコンテナ内でpodmanを利用するにはそれらを解除する必要がある。

## docker in dockerの公式イメージ

docker in dockerの公式イメージはalpiuneベースになっている。
普段使いとして向かないので注意

```shell
docker run --privileged hoge
または
docker run --security-opt seccomp=unconfined hoge
```

## dockerのプロキシ設定

~/.docker/configにプロキシ設定がされている場合はビルドしたコンテナに環境変数で自動的にプロキシ設定がされる。
これを防ぐためにはビルド時に環境変数no_proxyを渡して上げればよい
