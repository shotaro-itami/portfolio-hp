# portfolio-hp

ポートフォリオ兼、職務経歴書の静的 HTML です。

## 構成

- `index.html`
  - メインの職務経歴ページ
- `page2.html`
  - 人物紹介の補足ページ
- `まとめてく.txt`
  - 自分用メモ

## 使い方

ローカルで確認する場合は、`index.html` をブラウザで開いてください。

`page2.html` は `index.html` のフッターから遷移できます。

## 公開内容

- 職務要約
- スキルサマリ
- 職務経歴
- AI活用方針
- 自己PR
- 人物紹介の補足情報

## 補足

- 守秘情報や実データは掲載していません。
- 構成はシンプルな静的 HTML のため、そのまま Web サーバへ配置できます。

## 本番公開

現在の本番は GCE VM 上で次の構成です。

- Git 管理ディレクトリ: `/home/itamishotaro/portfolio-hp`
- release 格納: `/var/www/releases/portfolio-hp/<timestamp>`
- 公開 symlink:
  - `/var/www/html/index.html`
  - `/var/www/html/page2.html`
- ドメイン: `itamishotaro.com`
- 補助ドメイン: `www.itamishotaro.com`
- TLS: Cloudflare Origin Certificate

公開時は Git 管理ディレクトリから release を作り、公開 symlink だけ切り替えます。

```bash
cd /home/itamishotaro/portfolio-hp
git pull origin main
./deploy/release.sh
```

詳細な手順、rollback、Nginx 管理は `deploy/README.md` を正本にします。
