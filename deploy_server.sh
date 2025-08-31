#!/bin/bash
# Laravel项目服务器部署脚本

echo "开始在服务器上部署Laravel项目..."

# 设置变量
PROJECT_PATH="/var/www/html/laravel-project"

# 创建项目目录
sudo mkdir -p $PROJECT_PATH
cd $PROJECT_PATH

# 解压项目文件
sudo unzip -o /tmp/laravel-project.zip

# 设置权限
sudo chown -R www-data:www-data $PROJECT_PATH
sudo chmod -R 755 $PROJECT_PATH
sudo chmod -R 775 $PROJECT_PATH/storage
sudo chmod -R 775 $PROJECT_PATH/bootstrap/cache

# 安装PHP依赖
sudo composer install --optimize-autoloader --no-dev

# 设置环境配置
if [ ! -f .env ]; then
    sudo cp .env.example .env
    sudo php artisan key:generate
fi

# 运行数据库迁移
sudo php artisan migrate --force

# 创建符号链接
sudo php artisan storage:link

# 优化Laravel
sudo php artisan config:cache
sudo php artisan route:cache
sudo php artisan view:cache

# 配置Nginx
sudo tee /etc/nginx/sites-available/laravel-project > /dev/null <<EOF
server {
    listen 8888;
    server_name 47.237.130.22;
    root $PROJECT_PATH/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Content-Type-Options "nosniff";

    index index.html index.htm index.php;

    charset utf-8;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
EOF

# 启用站点
sudo ln -sf /etc/nginx/sites-available/laravel-project /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx

echo "Laravel项目部署完成！"
echo "访问地址: http://47.237.130.22:8888"