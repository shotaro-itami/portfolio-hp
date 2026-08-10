# Deploy Runbook

`portfolio-hp` の本番運用正本です。Git 作業コピーと公開中ファイルを分離し、release ディレクトリから symlink で配信します。

## 本番ディレクトリ責務

- Git checkout: `/home/itamishotaro/portfolio-hp`
- release 格納: `/var/www/releases/portfolio-hp/<timestamp>`
- 公開 symlink:
  - `/var/www/html/index.html`
  - `/var/www/html/page2.html`
  - `/var/www/html/architecture-diagram.html`

## デプロイ

```bash
cd /home/itamishotaro/portfolio-hp
git pull origin main
./deploy/release.sh
```

未マージの作業ブランチを本番 VM で一時確認する場合は、対象ブランチへ切り替えてから release を作ります。

```bash
git fetch origin
git switch <branch-name>
git pull --ff-only
./deploy/release.sh
```

`deploy/release.sh` は以下だけを行います。

1. release ディレクトリ作成
2. `index.html` / `page2.html` / `architecture-diagram.html` 配置
3. symlink 切替
4. `nginx -t`
5. `systemctl reload nginx`

更新途中に失敗しても既存の `/`、`/page2.html`、`/architecture-diagram.html` を残します。

## 本番構成資料の認証

`/architecture-diagram.html` は Nginx の Basic Auth で保護します。

パスワードファイルは Git 管理せず、本番 VM 上にだけ作成します。

```bash
sudo apt-get update
sudo apt-get install -y apache2-utils
sudo install -d -m 750 -o root -g www-data /etc/nginx/auth
sudo htpasswd -B -c /etc/nginx/auth/portfolio-architecture.htpasswd <username>
sudo chown root:www-data /etc/nginx/auth/portfolio-architecture.htpasswd
sudo chmod 640 /etc/nginx/auth/portfolio-architecture.htpasswd
sudo nginx -t
sudo systemctl reload nginx
```

ユーザーを追加する場合は `-c` を外します。

```bash
sudo htpasswd -B /etc/nginx/auth/portfolio-architecture.htpasswd <username>
```

Nginx 設定を変更した場合は、使用中の本番 Nginx 設定へ `deploy/nginx/itamishotaro.com.conf` の内容を反映してから `nginx -t` と reload を行います。`deploy/release.sh` は HTML の release 切替だけを行い、Nginx 設定やパスワードファイルは作成しません。

現在の本番では、実際に有効な設定は次の symlink から読み込まれます。

```bash
/etc/nginx/sites-enabled/itamishotaro.com -> /etc/nginx/sites-available/itamishotaro.com
```

そのため、反映先は `.conf` 付きではなく `/etc/nginx/sites-available/itamishotaro.com` です。

```bash
sudo cp deploy/nginx/itamishotaro.com.conf /etc/nginx/sites-available/itamishotaro.com
sudo nginx -T 2>/dev/null | grep -n -A6 -B3 'architecture-diagram'
sudo nginx -t
sudo systemctl reload nginx
```

## Rollback

```bash
sudo ln -sfnT /var/www/releases/portfolio-hp/<previous-timestamp>/index.html /var/www/html/index.html
sudo ln -sfnT /var/www/releases/portfolio-hp/<previous-timestamp>/page2.html /var/www/html/page2.html
sudo ln -sfnT /var/www/releases/portfolio-hp/<previous-timestamp>/architecture-diagram.html /var/www/html/architecture-diagram.html
sudo nginx -t
sudo systemctl reload nginx
```

## Files

- `release.sh`
- `nginx/itamishotaro.com.conf`
- `nginx/reading-time-tracker-rate-limit.conf`

## Notes

- `まとめてく.txt` は公開先へ置かない
- `/var/www/html` 配下は symlink だけを更新する
- 証明書ファイル `/etc/ssl/cloudflare/*` は Git 管理しない
