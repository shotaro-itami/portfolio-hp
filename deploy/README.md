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

`deploy/release.sh` は以下だけを行います。

1. release ディレクトリ作成
2. `index.html` / `page2.html` / `architecture-diagram.html` 配置
3. symlink 切替
4. `nginx -t`
5. `systemctl reload nginx`

更新途中に失敗しても既存の `/` と `/page2.html` を残します。

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
