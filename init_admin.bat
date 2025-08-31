@echo off
setlocal enabledelayedexpansion

echo ====================================
echo Laravel Admin System Initialization
echo ====================================

set "PROJECT_DIR=d:\xam\htdocs\laravel-project"
set "PHP_BIN=C:\xampp\php\php.exe"
set "ARTISAN=%PROJECT_DIR%\artisan"

cd /d "%PROJECT_DIR%"

echo.
echo 1. Installing dependencies...
if exist "%PROJECT_DIR%\composer.json" (
    if exist "%PROJECT_DIR%\composer.lock" (
        "%PHP_BIN%" "%PROJECT_DIR%\composer.phar" install --no-dev --optimize-autoloader
    )
)

echo.
echo 2. Running migrations...
"%PHP_BIN%" "%ARTISAN%" migrate:fresh --force

echo.
echo 3. Creating admin user...
"%PHP_PATH%" "%ARTISAN%" tinker --execute="
use App\Models\User;
use Illuminate\Support\Facades\Hash;
\$admin = User::create([
    'name' => 'Admin',
    'username' => 'admin',
    'email' => 'admin@example.com',
    'password' => Hash::make('admin123'),
    'is_admin' => true,
]);
echo 'Admin user created successfully!';
echo 'Username: admin';
echo 'Password: admin123';
"

echo.
echo 4. Clearing cache...
"%PHP_BIN%" "%ARTISAN%" cache:clear
"%PHP_BIN%" "%ARTISAN%" config:clear
"%PHP_BIN%" "%ARTISAN%" route:clear
"%PHP_BIN%" "%ARTISAN%" view:clear

echo.
echo ====================================
echo Initialization completed!
echo ====================================
echo.
echo Admin Login Credentials:
echo   Username: admin
echo   Password: admin123
echo   URL: http://localhost/laravel-project/public/admin/login
echo.
pause