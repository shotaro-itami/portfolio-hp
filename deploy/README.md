# Deploy Files

静的サイト `portfolio-hp` の本番公開用メモです。

## Files

- `nginx/itamishotaro.com.conf`

## Publish Flow

作業元:

- Git 管理ディレクトリ: `/home/itamishotaro/portfolio-hp`
- 公開先: `/var/www/html`

反映例:

```bash
cd /home/itamishotaro/portfolio-hp
git pull
sudo cp index.html /var/www/html/index.html
sudo cp page2.html /var/www/html/page2.html
sudo chown root:root /var/www/html/index.html /var/www/html/page2.html
sudo chmod 644 /var/www/html/index.html /var/www/html/page2.html
sudo nginx -t
sudo systemctl reload nginx
```

## Notes

- `まとめてく.txt` は公開先へ置かない
- `index.html.bak` や `index.nginx-debian.html` は整理候補
- 証明書ファイル `/etc/ssl/cloudflare/*` は Git 管理しない
