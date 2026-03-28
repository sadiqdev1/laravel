#!/usr/bin/env bash

# Exit on any error
set -e

echo "🚀 Starting Laravel 12 setup for Render..."

# 1️⃣ Install PHP dependencies
echo "📦 Installing Composer dependencies..."
composer install --no-dev --optimize-autoloader

# 2️⃣ Generate app key if not already set
echo "🔑 Generating APP_KEY..."
php artisan key:generate || true

# 3️⃣ Set permissions for storage and cache
echo "🔧 Setting permissions..."
chmod -R 775 storage bootstrap/cache

# 4️⃣ Clear & cache configs, routes, views
echo "🧹 Clearing & caching configs..."
php artisan config:clear
php artisan config:cache
php artisan route:cache
php artisan view:cache

# 5️⃣ Ensure SQLite database file exists
echo "🗄️ Ensuring SQLite database exists..."
mkdir -p database
touch database/database.sqlite

# 6️⃣ Run migrations (force for production)
echo "📑 Running migrations..."
php artisan migrate --force

echo "✅ Laravel setup completed!"