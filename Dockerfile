FROM php:8.2-apache

# 1️⃣ Install system dependencies
RUN apt-get update && apt-get install -y \
    git curl zip unzip libpng-dev libonig-dev libxml2-dev sqlite3 \
    && docker-php-ext-install pdo_mysql pdo_sqlite mbstring exif pcntl bcmath gd

# 2️⃣ Install Node.js 20 (for frontend build)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && apt-get install -y nodejs

# 3️⃣ Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 4️⃣ Set working directory
WORKDIR /var/www/html

# 5️⃣ Copy project files
COPY . .

# 6️⃣ Copy .env file into container
COPY .env /var/www/html/.env

# 7️⃣ Ensure SQLite database exists
RUN mkdir -p /var/www/html/database && touch /var/www/html/database/database.sqlite

# 8️⃣ Install PHP & Node dependencies
RUN composer install --no-dev --optimize-autoloader
RUN npm ci && npm run build

# 9️⃣ Clear Laravel caches
RUN php artisan config:clear && php artisan cache:clear && php artisan route:clear

# 🔟 Generate app key (if missing)
RUN php artisan key:generate --force || true

# 11️⃣ Run database migrations for SQLite
RUN php artisan migrate --force || true

# 12️⃣ Fix permissions for Laravel
RUN chown -R www-data:www-data storage bootstrap/cache database
RUN chmod -R 775 storage bootstrap/cache database

# 13️⃣ Enable Apache mod_rewrite & fix document root
RUN a2enmod rewrite
RUN sed -i 's|/var/www/html|/var/www/html/public|g' /etc/apache2/sites-available/000-default.conf

# 14️⃣ Expose port 80
EXPOSE 80
