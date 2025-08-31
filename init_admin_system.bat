@echo off
echo 正在初始化后台管理系统...
echo.
echo 1. 运行数据库迁移...
php artisan migrate --force

echo.
echo 2. 填充初始数据...
php artisan db:seed --force

echo.
echo 3. 创建管理员账户...
php artisan tinker --execute="
use App\Models\User;
use Illuminate\Support\Facades\Hash;
if (!User::where('username', 'admin')->first()) {
    User::create([
        'name' => '管理员',
        'username' => 'admin',
        'email' => 'admin@example.com',
        'password' => Hash::make('admin123'),
        'is_admin' => true,
    ]);
    echo '管理员账号创建成功！\\n';
    echo '用户名：admin\\n';
    echo '密码：admin123\\n';
} else {
    echo '管理员账号已存在！\\n';
}
"

echo.
echo 4. 清除缓存...
php artisan config:clear
php artisan cache:clear
php artisan route:clear

echo.
echo 初始化完成！
echo.
echo 管理员登录信息：
echo 用户名：admin
echo 密码：admin123
echo.
echo 访问地址：http://localhost:8000/admin/login
echo.
pause