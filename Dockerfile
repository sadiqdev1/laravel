FROM php:8.2-apache

# Copy ONLY test file
COPY test.php /var/www/html/

EXPOSE 80
