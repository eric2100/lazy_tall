#!/bin/bash
composer create-project --prefer-dist laravel/laravel public_html
cd public_html

# 權限設定
chown -R nginx:nginx .
chmod -R 777 bootstrap/cache
chmod -R 777 storage/ 
chmod 777 database/database.sqlite

# 修改 .env
sed -i 's/APP_LOCALE=en/APP_LOCALE=zh-Hant-TW/g' .env
sed -i 's/APP_FALLBACK_LOCALE=en/APP_FALLBACK_LOCALE=zh-Hant-TW/g' .env
sed -i 's/APP_FAKER_LOCALE=en_US/APP_FAKER_LOCALE=zh_TW/g' .env

cat > vite.config.js <<EOT
import { defineConfig } from "vite";
import laravel from "laravel-vite-plugin";

export default defineConfig({
  plugins: [
    laravel({
      input: ["resources/sass/app.scss", "resources/js/app.js"],
      refresh: true,
    }),
  ],
  css: {
    preprocessorOptions: {
      scss: {
        api: "modern-compiler", // or "modern"
      },
    },
  },
});
EOT

cat > .update <<EOT
#!/bin/bash
srcdir=/home/www3/public_html/
cd $srcdir
composer self-update
sleep 3
composer update -n
sleep 5
composer dump-autoload
sleep 5
npm update

sleep 5
npm run build
EOT

# 好用package
composer require livewire/livewire 
composer require laravel-frontend-presets/tall
composer require irazasyed/telegram-bot-sdk
composer require barryvdh/laravel-ide-helper
composer require diglactic/laravel-breadcrumbs
composer require jenssegers/agent
composer require spatie/laravel-permission

php artisan ui tall --auth
npm install && npm run build

#最佳化
php artisan optimize
php artisan optimize:clear
php artisan config:cache
php artisan route:cache
php artisan view:cache

# 產生設定
php artisan config:publish --all