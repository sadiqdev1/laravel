FROM php:8.2-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git curl libpng-dev libonig-dev libxml2-dev zip unzip

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath gd

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy app files
COPY . /var/www/html/

# Enable Apache rewrite module
RUN a2enmod rewrite

# Fix permissions and ownership
RUN chown -R www-data:www-data /var/www/html/
RUN chmod -R 775 /var/www/html/storage
RUN chmod -R 775 /var/www/html/bootstrap/cache

# Set Apache document root to public
RUN sed -i 's|/var/www/html|/
