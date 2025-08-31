#!/bin/bash
# 宝塔面板 Laravel 项目自动部署脚本
# 使用方法: chmod +x baota_deploy.sh && ./baota_deploy.sh

echo "🚀 开始在宝塔面板中部署Laravel项目..."

# 配置变量
PROJECT_DIR="/www/wwwroot/laravel-project"
DB_NAME="laravel_project"
DB_USER="laravel_user"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 打印彩色信息
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查是否为root用户
check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_error "请使用 root 用户运行此脚本"
        exit 1
    fi
}

# 检查宝塔面板是否安装
check_baota() {
    if [ ! -f "/www/server/panel/BT-Panel" ]; then
        print_error "未检测到宝塔面板，请先安装宝塔面板"
        exit 1
    fi
    print_info "检测到宝塔面板已安装"
}

# 检查必需软件是否安装
check_requirements() {
    print_info "检查必需软件..."
    
    # 检查Nginx
    if [ ! -d "/www/server/nginx" ]; then
        print_warning "Nginx未安装，请在宝塔面板中安装Nginx"
    else
        print_info "✓ Nginx已安装"
    fi
    
    # 检查PHP 8.2
    if [ ! -d "/www/server/php/82" ]; then
        print_warning "PHP 8.2未安装，请在宝塔面板中安装PHP 8.2"
    else
        print_info "✓ PHP 8.2已安装"
    fi
    
    # 检查MySQL
    if [ ! -d "/www/server/mysql" ]; then
        print_warning "MySQL未安装，请在宝塔面板中安装MySQL"
    else
        print_info "✓ MySQL已安装"
    fi
    
    # 检查Composer
    if ! command -v composer &> /dev/null; then
        print_warning "Composer未安装，正在安装..."
        curl -sS https://getcomposer.org/installer | php
        mv composer.phar /usr/local/bin/composer
        chmod +x /usr/local/bin/composer
    fi
    print_info "✓ Composer已安装"
}

# 创建项目目录
create_project_dir() {
    print_info "创建项目目录..."
    
    if [ -d "$PROJECT_DIR" ]; then
        print_warning "项目目录已存在，正在清理..."
        rm -rf ${PROJECT_DIR}/*
    else
        mkdir -p "$PROJECT_DIR"
    fi
    
    print_info "✓ 项目目录创建完成"
}

# 解压项目文件
extract_project() {
    print_info "解压项目文件..."
    
    if [ -f "/tmp/laravel-project.zip" ]; then
        cd "$PROJECT_DIR"
        unzip -o /tmp/laravel-project.zip
        rm -f /tmp/laravel-project.zip
        print_info "✓ 项目文件解压完成"
    else
        print_error "未找到项目压缩包，请先上传 laravel-project.zip 到 /tmp/ 目录"
        exit 1
    fi
}

# 设置文件权限
set_permissions() {
    print_info "设置文件权限..."
    
    cd "$PROJECT_DIR"
    chown -R www:www .
    chmod -R 755 .
    chmod -R 775 storage bootstrap/cache
    
    print_info "✓ 文件权限设置完成"
}

# 安装PHP依赖
install_dependencies() {
    print_info "安装PHP依赖..."
    
    cd "$PROJECT_DIR"
    
    # 配置Composer镜像
    composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/
    
    # 安装依赖
    composer install --optimize-autoloader --no-dev --no-interaction
    
    if [ $? -eq 0 ]; then
        print_info "✓ PHP依赖安装完成"
    else
        print_error "PHP依赖安装失败"
        exit 1
    fi
}

# 配置环境文件
setup_env() {
    print_info "配置环境文件..."
    
    cd "$PROJECT_DIR"
    
    if [ ! -f ".env" ]; then
        cp .env.example .env
    fi
    
    # 生成应用密钥
    php artisan key:generate --force
    
    print_info "✓ 环境文件配置完成"
    print_warning "请手动编辑 .env 文件配置数据库连接信息"
}

# 运行数据库迁移
run_migrations() {
    print_info "运行数据库迁移..."
    
    cd "$PROJECT_DIR"
    php artisan migrate --force
    
    if [ $? -eq 0 ]; then
        print_info "✓ 数据库迁移完成"
    else
        print_warning "数据库迁移失败，请检查数据库配置"
    fi
}

# 创建符号链接
create_storage_link() {
    print_info "创建存储符号链接..."
    
    cd "$PROJECT_DIR"
    php artisan storage:link
    
    print_info "✓ 存储符号链接创建完成"
}

# 优化Laravel
optimize_laravel() {
    print_info "优化Laravel应用..."
    
    cd "$PROJECT_DIR"
    php artisan config:cache
    php artisan route:cache
    php artisan view:cache
    php artisan optimize
    
    print_info "✓ Laravel优化完成"
}

# 配置Nginx虚拟主机
configure_nginx() {
    print_info "配置Nginx虚拟主机..."
    
    # 创建Nginx配置文件
    cat > /www/server/panel/vhost/nginx/laravel-project.conf << 'EOF'
server {
    listen 8888;
    server_name 47.237.130.22;
    root /www/wwwroot/laravel-project/public;

    index index.html index.htm index.php;

    charset utf-8;

    # 安全头
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;

    # Laravel路由
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    # PHP处理
    location ~ \.php$ {
        fastcgi_pass unix:/tmp/php-cgi-82.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    # 隐藏敏感文件
    location ~ /\.(?!well-known).* {
        deny all;
    }

    # 静态文件缓存
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # 访问日志
    access_log /www/wwwlogs/laravel-project.log;
    error_log /www/wwwlogs/laravel-project.error.log;
}
EOF

    # 重载Nginx配置
    /www/server/nginx/sbin/nginx -t
    if [ $? -eq 0 ]; then
        /www/server/nginx/sbin/nginx -s reload
        print_info "✓ Nginx配置完成"
    else
        print_error "Nginx配置文件有错误，请检查"
    fi
}

# 创建管理员用户
create_admin_user() {
    print_info "创建管理员用户..."
    
    cd "$PROJECT_DIR"
    php artisan db:seed --class=AdminUserSeeder
    
    if [ $? -eq 0 ]; then
        print_info "✓ 管理员用户创建完成"
        print_info "默认登录信息："
        print_info "  邮箱: admin@example.com"
        print_info "  密码: password"
        print_warning "首次登录后请立即修改密码！"
    else
        print_warning "管理员用户创建失败，请手动运行数据填充"
    fi
}

# 显示部署结果
show_result() {
    print_info "🎉 Laravel项目部署完成！"
    echo ""
    print_info "访问地址："
    print_info "  网站首页: http://47.237.130.22:8888"
    print_info "  管理后台: http://47.237.130.22:8888/admin/login"
    echo ""
    print_info "后续步骤："
    print_info "1. 在宝塔面板中检查网站配置"
    print_info "2. 编辑 .env 文件配置数据库信息"
    print_info "3. 访问网站测试功能"
    print_info "4. 修改默认管理员密码"
    echo ""
    print_info "如有问题，请查看部署日志或联系管理员"
}

# 主函数
main() {
    echo "========================================="
    echo "     宝塔面板 Laravel 自动部署脚本      "
    echo "========================================="
    echo ""
    
    check_root
    check_baota
    check_requirements
    create_project_dir
    extract_project
    set_permissions
    install_dependencies
    setup_env
    run_migrations
    create_storage_link
    optimize_laravel
    configure_nginx
    create_admin_user
    show_result
}

# 执行主函数
main "$@"