# Use official PHP CLI image
FROM php:8.2-cli

# Set working directory
WORKDIR /var/www/html

# Install system dependencies + Node.js for Vite
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libsqlite3-dev \
    curl \
    nodejs \
    npm \
    && docker-php-ext-install pdo_sqlite

# Copy app code
COPY . .

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Install Node dependencies and build frontend assets
RUN npm install
RUN npm run build

# Expose port 8000
EXPOSE 8000

# Copy setup script
COPY render-setup.sh /tmp/render-setup.sh
RUN chmod +x /tmp/render-setup.sh

# Run setup script and start Laravel
CMD ["/bin/bash", "/tmp/render-setup.sh"]
