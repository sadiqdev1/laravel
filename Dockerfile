FROM php:8.2-apache

# 1️⃣ Install dependencies
RUN apt-get update && apt-get install -y \
    git curl zip unzip libpng-dev libonig-dev libxml2-dev sqlite3 \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# 2️⃣ Install Node.js (for frontend build)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && apt-get install -y nodejs

# 3️⃣ Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 4️⃣ Set working directory
WORKDIR /var/www/html

# 5️⃣ Copy app files
COPY . .

# 6️⃣ Copy environment file
COPY .env /var/www/html/.env

# 7️⃣ Create SQLite database file (important!)
RUN mkdir -p /var/www/html/database && touch /var/www/html/database/database.sqlite

# 8️⃣ Install PHP & Node dependencies
RUN composer install --no-dev --optimize-autoloader
RUN npm install && npm run build

# 9️⃣ Generate app key (only if empty)
# (If APP_KEY is already in .env, this command will safely skip)
RUN php artisan key:generate --force || true

# 🔟 Run migrations for SQLite (no shell access needed)
RUN php artisan migrate --force || true

# 11️⃣ Set permissions for Laravel
RUN chown -R www-data:www-data storage bootstrap/cache database
RUN chmod -R 775 storage bootstrap/cache database

# 12️⃣ Apache setup
RUN a2enmod rewrite
RUN sed -i 's|/var/www/html|/var/www/html/public|g' /etc/apache2/sites-available/000-default.conf

# 13️⃣ Expose port 80
EXPOSE 80
