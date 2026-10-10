# Imagem oficial do PHP com Apache
FROM php:8.3-apache

# Instala dependências do sistema e extensões necessárias para o Laravel
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libzip-dev \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

# Ativa o módulo de reescrita do Apache (mod_rewrite para URLs amigáveis do Laravel)
RUN a2enmod rewrite

# Configura o Apache para apontar o DocumentRoot diretamente para a pasta /public do Laravel
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/conf-available/*.conf

# Instala o Composer copiando o executável oficial
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Define o diretório de trabalho no container
WORKDIR /var/www/html

# Copia todos os arquivos do projeto para o container
COPY . /var/www/html

# Instala as dependências do Laravel via Composer para produção
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Ajusta as permissões necessárias para o Laravel (storage e cache)
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Expõe a porta 80
EXPOSE 80

# Comando para iniciar o Apache em primeiro plano
CMD ["apache2-foreground"]
