# 宝塔面板 Laravel 项目快速配置

## 🎯 一键部署命令

### 1. 上传文件到服务器
```bash
# 上传项目压缩包
scp laravel-project.zip root@47.237.130.22:/tmp/

# 上传部署脚本
scp baota_deploy.sh root@47.237.130.22:/tmp/
```

### 2. 执行自动部署
```bash
# 连接服务器
ssh root@47.237.130.22

# 给脚本执行权限并运行
chmod +x /tmp/baota_deploy.sh && /tmp/baota_deploy.sh
```

## 📋 宝塔面板手动配置清单

### ✅ 1. 软件安装确认
进入宝塔面板 → 软件商店，确认已安装：
- [ ] Nginx 1.22+
- [ ] PHP 8.2 (包含所有必需扩展)
- [ ] MySQL 8.0+ / MariaDB 10.6+
- [ ] Composer
- [ ] Node.js 18+ (可选)

### ✅ 2. 创建网站
宝塔面板 → 网站 → 添加站点
```
域名: 47.237.130.22:8888
根目录: /www/wwwroot/laravel-project
PHP版本: 8.2
数据库: laravel_project
用户: laravel_user
```

### ✅ 3. 网站设置
进入网站设置：
- [ ] 运行目录: `/public`
- [ ] 默认首页: `index.php`
- [ ] PHP版本: 8.2
- [ ] 伪静态: Laravel

### ✅ 4. 数据库配置 (.env)
```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=laravel_project
DB_USERNAME=laravel_user
DB_PASSWORD=您的数据库密码
```

### ✅ 5. 必需的Laravel命令
```bash
cd /www/wwwroot/laravel-project

# 安装依赖
composer install --optimize-autoloader --no-dev

# 配置环境
php artisan key:generate
php artisan migrate --force
php artisan storage:link

# 优化缓存
php artisan optimize
```

## 🔧 宝塔面板特殊配置

### PHP设置优化
进入宝塔面板 → PHP → 设置：
1. **禁用函数** 中移除以下函数：
   - exec, shell_exec, system, passthru
   - proc_open, proc_get_status

2. **性能调整**：
   - memory_limit = 256M
   - max_execution_time = 300
   - upload_max_filesize = 100M
   - post_max_size = 100M

3. **安装扩展**：
   - fileinfo
   - zip
   - curl
   - mbstring
   - xml

### Nginx伪静态规则
```nginx
location / {
    try_files $uri $uri/ /index.php?$query_string;
}
```

### 安全设置
1. **SSL证书**：宝塔面板 → 网站设置 → SSL
2. **防火墙**：开放8888端口
3. **访问限制**：可设置IP白名单

## 📊 监控与维护

### 1. 日志查看
- Nginx日志: `/www/wwwlogs/laravel-project.log`
- Laravel日志: `/www/wwwroot/laravel-project/storage/logs/laravel.log`

### 2. 性能监控
宝塔面板提供：
- CPU使用率监控
- 内存使用监控
- 磁盘空间监控
- 网络流量监控

### 3. 自动备份
宝塔面板 → 计划任务 → 备份网站/数据库

## 🚨 常见问题解决

### 问题1：500错误
```bash
# 检查权限
chown -R www:www /www/wwwroot/laravel-project
chmod -R 775 /www/wwwroot/laravel-project/storage
```

### 问题2：数据库连接失败
- 检查宝塔面板数据库设置
- 确认.env配置正确
- 测试数据库连接

### 问题3：Composer安装慢
```bash
# 使用国内镜像
composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/
```

## 📞 技术支持

如果遇到问题，可以：
1. 查看宝塔面板系统日志
2. 检查Laravel应用日志
3. 查阅本项目的 BAOTA_DEPLOYMENT.md 详细文档

---

> 💡 **提示**: 使用自动部署脚本 `baota_deploy.sh` 可以大大简化部署过程，建议优先使用自动化方案。