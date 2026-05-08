# 勤怠システム(B)

本アプリケーションは従業員の勤怠を管理するWebアプリケーションです。
勤怠チュートリアルで作成したアプリケーションをベースに、機能を追加しました。

# サンプルアプリケーション（Docker 版手順）

### 1) dockerコンテナ起動(Rails Server起動)

```bash
$ docker-compose up -d
$ docker attach attendance_app-web-1
```

# gemfile変更後の docker-compose run --rm web bundle install も必要

## 権限がなく実行できないときは　docker compose build

### 9) rails c やrails db コマンド実行時

```bash
$ docker compose run --rm web bin/rails c
$ docker compose run --rm web bin/rails db:(各種コマンド)
```

# docker compose run --rm web bin/ を前に書く
