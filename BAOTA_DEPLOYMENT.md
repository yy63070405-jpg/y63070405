# 宝塔面板 Laravel 项目部署指南

## 📋 部署前准备

### 服务器环境要求
- 服务器IP: 47.237.130.22
- 端口: 8888
- 操作系统: Linux (CentOS/Ubuntu)
- 宝塔面板已安装

### 必需软件栈 (在宝塔面板中安装)
- ✅ Nginx 1.22+
- ✅ PHP 8.2+ (需要安装以下扩展)
  - php-fpm
  - php-mysql
  - php-curl
  - php-zip
  - php-xml
  - php-mbstring
  - php-json
  - php-fileinfo
  - php-tokenizer
- ✅ MySQL 8.0+ / MariaDB 10.6+
- ✅ Composer (PHP包管理器)
- ✅ Node.js 18+ (用于前端资源构建)

## 🚀 宝塔面板部署步骤

### 1. 登录宝塔面板
访问: `http://47.237.130.22:8888/login`
使用您的宝塔管理员账户登录

### 2. 安装必需软件
在宝塔面板 → 软件商店 → 安装以下软件：
1. **Nginx** (推荐最新稳定版)
2. **PHP 8.2** (必须包含所有必需扩展)
3. **MySQL 8.0** 或 **MariaDB 10.6**
4. **Composer** (PHP依赖管理)
5. **PM2管理器** (可选，用于Node.js进程管理)

### 3. 创建网站
1. 进入宝塔面板 → 网站 → 添加站点
2. 填写以下信息：
   - 域名: `47.237.130.22:8888`
   - 根目录: `/www/wwwroot/laravel-project`
   - PHP版本: 选择 PHP 8.2
   - 创建数据库: 是
   - 数据库名: `laravel_project`
   - 数据库用户: `laravel_user`
   - 数据库密码: 自动生成或自定义

### 4. 上传项目文件
#### 方法一：文件管理器上传
1. 进入宝塔面板 → 文件 → 进入网站根目录 `/www/wwwroot/laravel-project`
2. 删除默认的 `index.html` 等文件
3. 上传项目压缩包 `laravel-project.zip`
4. 解压缩到当前目录

#### 方法二：使用终端上传（推荐）
在本地执行：
```bash
scp laravel-project.zip root@47.237.130.22:/www/wwwroot/laravel-project/
```

### 5. 配置网站运行目录
1. 进入宝塔面板 → 网站 → 找到刚创建的网站 → 设置
2. 修改 **运行目录** 为 `/public`
3. 修改 **默认首页** 为 `index.php`

### 6. 配置PHP
1. 进入网站设置 → PHP → PHP版本 → 选择 PHP 8.2
2. 禁用函数中删除以下函数（如果存在）：
   - `exec`
   - `shell_exec`
   - `system`
   - `passthru`
   - `proc_open`
   - `proc_get_status`

### 7. 执行Laravel部署命令
进入宝塔面板 → 文件 → 进入项目根目录，然后点击 **终端**，执行以下命令：

```bash
# 进入项目目录
cd /www/wwwroot/laravel-project

# 解压项目文件（如果还没解压）
unzip -o laravel-project.zip
rm laravel-project.zip

# 设置权限
chown -R www:www /www/wwwroot/laravel-project
chmod -R 755 /www/wwwroot/laravel-project
chmod -R 775 /www/wwwroot/laravel-project/storage
chmod -R 775 /www/wwwroot/laravel-project/bootstrap/cache

# 安装PHP依赖
composer install --optimize-autoloader --no-dev

# 配置环境文件
cp .env.example .env

# 生成应用密钥（如果还没生成）
php artisan key:generate

# 运行数据库迁移
php artisan migrate --force

# 创建存储链接
php artisan storage:link

# 优化Laravel
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

### 8. 配置环境变量 (.env)
编辑 `.env` 文件，修改以下配置：

```env
APP_NAME=Laravel
APP_ENV=production
APP_KEY=base64:xxx... (自动生成的密钥)
APP_DEBUG=false
APP_URL=http://47.237.130.22:8888

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=laravel_project
DB_USERNAME=laravel_user
DB_PASSWORD=您创建的数据库密码

# 其他配置保持默认...
```

### 9. 配置Nginx伪静态
在宝塔面板 → 网站设置 → 伪静态 → 选择 **Laravel** 或手动添加：

```nginx
location / {
    try_files $uri $uri/ /index.php?$query_string;
}

location ~ \.php$ {
    fastcgi_pass unix:/tmp/php-cgi-82.sock;
    fastcgi_index index.php;
    include fastcgi_params;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
}
```

### 10. 配置SSL（可选但推荐）
1. 进入网站设置 → SSL
2. 选择 Let's Encrypt 免费证书或上传自有证书
3. 开启强制HTTPS

### 11. 创建管理员账户
在终端中执行：
```bash
cd /www/wwwroot/laravel-project
php artisan db:seed --class=AdminUserSeeder
```

## ✅ 验证部署

访问以下地址确认部署成功：
- 网站首页: `http://47.237.130.22:8888`
- 管理后台: `http://47.237.130.22:8888/admin/login`

默认管理员登录信息：
- 邮箱: `admin@example.com`
- 密码: `password`

**⚠️ 重要：首次登录后立即修改密码！**

## 🔧 常见问题解决

### 1. 500错误
```bash
# 检查Laravel日志
tail -f /www/wwwroot/laravel-project/storage/logs/laravel.log

# 清理缓存
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear
```

### 2. 权限问题
```bash
# 重新设置权限
chown -R www:www /www/wwwroot/laravel-project
chmod -R 775 /www/wwwroot/laravel-project/storage
chmod -R 775 /www/wwwroot/laravel-project/bootstrap/cache
```

### 3. 数据库连接失败
- 检查宝塔面板 → 数据库 → 确认数据库和用户是否创建成功
- 验证 `.env` 文件中的数据库配置是否正确
- 确保MySQL服务正在运行

### 4. Composer安装失败
```bash
# 更换国内镜像
composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/
# 重新安装
composer install --optimize-autoloader --no-dev
```

## 📊 性能优化建议

1. **开启OPcache**: 宝塔面板 → PHP设置 → 性能调整 → OPcache
2. **配置队列**: 使用 Supervisor 管理Laravel队列
3. **Redis缓存**: 安装Redis并配置Laravel缓存驱动
4. **CDN加速**: 配置静态资源CDN加速

## 🛡️ 安全建议

1. 修改默认SSH端口
2. 配置防火墙规则
3. 定期更新系统和软件
4. 启用宝塔面板的安全模式
5. 定期备份数据库和文件

## 📝 维护命令

```bash
# 查看队列状态
php artisan queue:work

# 清理缓存
php artisan optimize:clear

# 更新项目
git pull origin main
composer install --optimize-autoloader --no-dev
php artisan migrate --force
php artisan optimize
```

完成以上步骤后，您的Laravel项目就成功部署在宝塔面板上了！