# 勤怠システム(A)

本アプリケーションは従業員の勤怠を管理するWebアプリケーションです。
勤怠チュートリアルで作成したアプリケーションをベースに、機能を追加しました。

# 主な機能

### 一般ユーザー
- ログイン / ログアウト
- アカウント作成
- 個人情報編集
- 勤怠表示（月 / 週単位切り替え・前週/次週ナビゲーション）
- 勤怠一括編集（月単位）
- 出勤・退勤時間の記録
- 在社時間の自動計算（15分単位）
- 勤怠表の曜日色分け（土曜：青 / 日曜：赤）

### 管理者
- ユーザー一覧表示（名前の部分一致検索・ページネーション対応）
- 基本勤務時間一括修正
- 他ユーザーの勤怠記録の編集

## 技術スタック

| 種別              | 技術                          |
| ----------------- | ----------------------------- |
| 言語              | Ruby 3.0.6                    |
| フレームワーク    | Rails 7.1                     |
| DB（本番）        | PostgreSQL（pg）              |
| DB（開発/テスト） | Docker (mysql2)               |
| フロントエンド    | Bootstrap 3, jQuery           |
| 認証              | bcrypt（has_secure_password） |
| インフラ          | Docker / Docker Compose       |

## データベース構成

| 環境               | アダプター      | 理由                              |
| ------------------ | --------------- | --------------------------------- |
| development / test | mysql2          | Docker で MySQL コンテナを使用    |
| production         | pg (PostgreSQL) | Heroku 等の本番環境に合わせた設定 |

## ローカル環境セットアップ

```
# リポジトリをクローン

git clone https://github.com/YoshitatsuSaita/Attendance_A
cd Attendance_a

# コンテナ起動
docker compose up -d

# DB 作成・マイグレーション・seed
docker compose exec web bin/rails db:create db:migrate db:seed

```

## テスト実行

```bash
$ docker compose exec web bin/rails test
```
