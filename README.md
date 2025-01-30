# wp-wis 
## WordPress: Nginx Configuration Best Practices 

### General Best Practices
- Keep Nginx Updated: Always use the latest stable version of Nginx to benefit from security patches and performance improvements.
- Use a Dedicated User: Run Nginx as a non-root user with limited permissions to enhance security.
- Enable Gzip Compression: Compress static assets to reduce load times.
- Set Appropriate File Permissions: Ensure WordPress files and directories have secure permissions (e.g., 755 for directories, 644 for files).
-  Limit Direct Access to Sensitive Files: Restrict access to files like wp-config.php and .htaccess.
- Enable Caching: Use FastCGI caching or Redis/Memcached to improve performance.
- Optimize PHP-FPM: Configure PHP-FPM to work efficiently with Nginx.

### 1. Setting Up Server Blocks

Server blocks in Nginx allow you to host multiple websites on the same server. Each block represents a virtual host.

Configuration for WordPress
```
server {
    listen 80;
    server_name douglas.com www.douglas.com;

    root /var/www/douglas.com;
    index index.php index.html index.htm;

    # Logging
    access_log /var/log/nginx/douglas.com.access.log;
    error_log /var/log/nginx/douglas.com.error.log;

    # WordPress Permalinks
    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    # Deny access to .htaccess and other sensitive files
    location ~ /\.ht {
        deny all;
    }

    # Pass PHP requests to PHP-FPM
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock; # Adjust PHP version as needed
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 30d;
        add_header Cache-Control "public, no-transform";
    }

    # Disable access to wp-config.php
    location = /wp-config.php {
        deny all;
    }
}
```
### 2. Configuring Virtual Hosts

Create a configuration file in /etc/nginx/sites-available/:

`sudo nano /etc/nginx/sites-available/example.com`

Paste the server block configuration.

Create a symbolic link to sites-enabled:

`sudo ln -s /etc/nginx/sites-available/example.com /etc/nginx/sites-enabled/`

Test the configuration and reload Nginx:

`sudo nginx -t`
`sudo systemctl reload nginx`

### 3. Secure Configuration with SSL

```
server {
    listen 80;
    server_name douglas.com www.douglas.com;

    # Redirect HTTP to HTTPS
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_name douglas.com www.douglas.com;

    ssl_certificate /etc/letsencrypt/live/douglas.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/douglas.com/privkey.pem;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    root /var/www/example.com;
    index index.php index.html index.htm;

    # Security Headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;

    # Content Security Policy (CSP)
    # Adjust this based on your site's requirements
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' https://cdn.example.com; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; img-src 'self' data: https://*.example.com; font-src 'self' https://fonts.gstatic.com; frame-ancestors 'self';" always;

    # WordPress Permalinks
    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    # PHP-FPM Configuration
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

    # Logging
    access_log /var/log/nginx/douglas.com.access.log;
    error_log /var/log/nginx/douglas.com.error.log;

    # Static Asset Caching
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 30d;
        add_header Cache-Control "public, no-transform";
    }
}
```
