FROM php:8.2-apache

# 1️⃣ Install system dependencies (✅ fixed: add libsqlite3-dev)
RUN apt-get update && apt-get install -y \
    git curl zip unzip libpng-dev libonig-dev libxml2-dev libsqlite3-dev sqlite3 \
    && docker-php-ext-install pdo_mysql pdo_sqlite mbstring exif pcntl bcmath gd

# 2️⃣ Install Node.js 20
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && apt-get install -y nodejs

# 3️⃣ Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 4️⃣ Set working directory
WORKDIR /var/www/html

# 5️⃣ Copy all project files
COPY . .

# 6️⃣ Copy .env
COPY .env /var/www/html/.env

# 7️⃣ Create SQLite database file
RUN mkdir -p /var/www/html/database && touch /var/www/html/database/database.sqlite

# 8️⃣ Install dependencies
RUN composer install --no-dev --optimize-autoloader
RUN npm install && npm run build

# 9️⃣ Clear caches to avoid config issues
RUN php artisan config:clear && php artisan cache:clear && php artisan route:clear

# 🔟 Generate app key (safe if already exists)
RUN php artisan key:generate --force || true

# 11️⃣ Run database migrations
RUN php artisan migrate --force || true

# 12️⃣ Fix permissions
RUN chown -R www-data:www-data storage bootstrap/cache database
RUN chmod -R 775 storage bootstrap/cache database

# 13️⃣ Enable Apache rewrite + set document root
RUN a2enmod rewrite
RUN sed -i 's|/var/www/html|/var/www/html/public|g' /etc/apache2/sites-available/000-default.conf

# 14️⃣ Expose port
EXPOSE 80
