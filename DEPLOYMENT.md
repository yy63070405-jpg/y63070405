# Laravel项目部署指南

## 部署准备
项目已经完成以下准备工作：
1. ✅ 生成应用密钥 (APP_KEY)
2. ✅ 修改环境配置为生产环境
3. ✅ 构建前端资源 (npm run build)
4. ✅ 缓存配置和路由
5. ✅ 创建项目压缩包 (laravel-project.zip)

## 服务器信息
- 服务器IP: 47.237.130.22
- 用户名: root
- 密码: Dong721521@
- 目标端口: 8888
- 项目路径: /var/www/html/laravel-project

## 部署步骤

### 1. 上传文件到服务器
使用以下命令将文件上传到服务器：

```bash
# 上传项目压缩包
scp laravel-project.zip root@47.237.130.22:/tmp/

# 上传部署脚本
scp deploy_server.sh root@47.237.130.22:/tmp/
```

### 2. 连接服务器并执行部署
```bash
# 连接服务器
ssh root@47.237.130.22

# 给部署脚本执行权限
chmod +x /tmp/deploy_server.sh

# 执行部署脚本
/tmp/deploy_server.sh
```

### 3. 验证部署
部署完成后，访问以下地址验证：
- 主页: http://47.237.130.22:8888
- 管理后台: http://47.237.130.22:8888/admin/login

## 部署脚本功能
deploy_server.sh 脚本将自动完成：
1. 创建项目目录
2. 解压项目文件
3. 设置正确的文件权限
4. 安装PHP依赖
5. 运行数据库迁移
6. 配置Nginx虚拟主机
7. 启用站点并重启Nginx

## 注意事项
1. 确保服务器已安装：
   - PHP 8.2+
   - Nginx
   - MySQL/MariaDB
   - Composer

2. 如果遇到数据库连接问题，需要在服务器上：
   - 创建数据库
   - 配置.env文件中的数据库连接信息

3. 检查防火墙设置，确保8888端口已开放

## 故障排除
如果部署过程中遇到问题：

1. 检查日志：
   ```bash
   sudo tail -f /var/log/nginx/error.log
   sudo tail -f /var/www/html/laravel-project/storage/logs/laravel.log
   ```

2. 检查权限：
   ```bash
   sudo chown -R www-data:www-data /var/www/html/laravel-project
   sudo chmod -R 775 /var/www/html/laravel-project/storage
   ```

3. 清理缓存：
   ```bash
   cd /var/www/html/laravel-project
   sudo php artisan cache:clear
   sudo php artisan config:clear
   sudo php artisan route:clear
   ```

## 管理员账户
部署完成后，运行以下命令创建管理员账户：
```bash
cd /var/www/html/laravel-project
sudo php artisan db:seed --class=AdminUserSeeder
```

默认管理员账户：
- 用户名: admin@example.com
- 密码: password

请在首次登录后立即修改密码！