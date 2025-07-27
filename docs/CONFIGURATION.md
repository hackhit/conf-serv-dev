# ⚙️ Guía de Configuración Avanzada

## 📋 Configuraciones Personalizadas

### 🔧 Modificar IPs del Proyecto

Si necesitas usar IPs diferentes a las predeterminadas:

#### 1. Cambiar IP Interna (192.168.1.167)

```bash
# Editar configuración de red
sudo nano network/01-network-config.yaml

# Cambiar:
addresses:
  - 192.168.1.167/24  # <- Nueva IP aquí
```

#### 2. Cambiar IP Externa (38.10.252.121)

```bash
# Editar zonas DNS
sudo nano dns/db.tallerchevrolet.com
sudo nano dns/db.repuestoschevy.com
sudo nano dns/db.deosvenezuela.com

# Cambiar todos los registros A:
@       IN      A       TU_IP_EXTERNA
www     IN      A       TU_IP_EXTERNA
# etc...
```

#### 3. Actualizar Scripts

```bash
# Editar scripts para usar nuevas IPs
sudo nano scripts/deploy_server.sh
sudo nano scripts/ssl_setup.sh
sudo nano scripts/server_check.sh

# Buscar y reemplazar IPs antiguas
```

---

## 🌐 Agregar Nuevos Dominios

### Proceso Completo para Nuevo Dominio

#### 1. Crear Zona DNS

```bash
# Copiar plantilla
cp examples/additional-domains/db.example-domain.com dns/db.tu-dominio.com

# Editar zona DNS
nano dns/db.tu-dominio.com

# Reemplazar "example-domain.com" con "tu-dominio.com"
# Incrementar serial: 2024072601 -> 2024072602
```

#### 2. Agregar Zona a BIND9

```bash
# Editar configuración principal
nano dns/named.conf.local

# Agregar nueva zona:
zone "tu-dominio.com" {
    type master;
    file "/etc/bind/db.tu-dominio.com";
    allow-transfer { any; };
    allow-query { any; };
    notify yes;
};
```

#### 3. Crear Virtual Host

```bash
# Copiar plantilla
cp examples/additional-domains/example-domain.com.conf apache/tu-dominio.com.conf

# Editar configuración
nano apache/tu-dominio.com.conf

# Reemplazar "example-domain.com" con "tu-dominio.com"
```

#### 4. Implementar Cambios

```bash
# Copiar archivos al servidor
sudo cp dns/db.tu-dominio.com /etc/bind/
sudo cp dns/named.conf.local /etc/bind/
sudo cp apache/tu-dominio.com.conf /etc/apache2/sites-available/

# Crear directorio web
sudo mkdir -p /var/www/tu-dominio.com
sudo chown www-data:www-data /var/www/tu-dominio.com

# Habilitar sitio
sudo a2ensite tu-dominio.com.conf

# Reiniciar servicios
sudo systemctl reload bind9
sudo systemctl reload apache2
```

---

## 🔐 Configuración de Seguridad Avanzada

### 🛡️ Configurar Autenticación por Directorios

#### 1. Crear Archivo de Contraseñas

```bash
# Para área administrativa
sudo htpasswd -c /etc/apache2/.htpasswd-admin usuario1
sudo htpasswd /etc/apache2/.htpasswd-admin usuario2

# Para área financiera (más estricta)
sudo htpasswd -c /etc/apache2/.htpasswd-finanzas admin_finanzas

# Para desarrolladores
sudo htpasswd -c /etc/apache2/.htpasswd-dev dev1
sudo htpasswd /etc/apache2/.htpasswd-dev dev2
```

#### 2. Configurar Restricciones por IP

```apache
# En tu Virtual Host:
<Directory /var/www/tu-dominio.com/admin>
    AuthType Basic
    AuthName "Área Administrativa"
    AuthUserFile /etc/apache2/.htpasswd-admin
    Require valid-user
    
    # Restringir por IP también
    Require ip 192.168.1
    Require ip 10.0.0
</Directory>
```

### 🔒 SSL/TLS Personalizado

#### 1. Configuración SSL Avanzada

```apache
# En tu Virtual Host HTTPS:
SSLEngine on
SSLProtocol all -SSLv3 -TLSv1 -TLSv1.1
SSLCipherSuite ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256
SSLHonorCipherOrder off
SSLSessionTickets off

# OCSP Stapling
SSLUseStapling On
SSLStaplingResponderTimeout 5
SSLStaplingReturnResponderErrors off
```

#### 2. Headers de Seguridad Reforzados

```apache
# Content Security Policy estricto
Header always set Content-Security-Policy "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; font-src 'self'; connect-src 'self'; frame-ancestors 'none';"

# Headers adicionales
Header always set X-Content-Type-Options nosniff
Header always set X-Frame-Options DENY
Header always set X-XSS-Protection "1; mode=block"
Header always set Referrer-Policy "strict-origin-when-cross-origin"
Header always set Permissions-Policy "geolocation=(), microphone=(), camera=()"
```

---

## 📧 Configuración de Correo Electrónico

### 🎯 Configurar Postfix para Envío

#### 1. Instalar y Configurar Postfix

```bash
# Instalar Postfix
sudo apt install -y postfix mailutils

# Configurar como Internet Site
sudo dpkg-reconfigure postfix
```

#### 2. Configuración Básica

```bash
# Editar configuración principal
sudo nano /etc/postfix/main.cf

# Configuraciones importantes:
myhostname = mail.tu-dominio.com
mydomain = tu-dominio.com
myorigin = $mydomain
inet_interfaces = all
mydestination = $myhostname, localhost.$mydomain, localhost, $mydomain
```

#### 3. Configurar SPF, DKIM y DMARC

```bash
# Instalar OpenDKIM
sudo apt install -y opendkim opendkim-tools

# Generar claves DKIM
sudo mkdir -p /etc/opendkim/keys/tu-dominio.com
sudo opendkim-genkey -s default -d tu-dominio.com -D /etc/opendkim/keys/tu-dominio.com/
```

### 📨 Configurar Aliases de Correo

```bash
# Editar aliases
sudo nano /etc/aliases

# Agregar:
root: admin@tu-dominio.com
postmaster: admin@tu-dominio.com
abuse: admin@tu-dominio.com
webmaster: admin@tu-dominio.com

# Actualizar base de datos
sudo newaliases
```

---

## 📊 Monitoreo y Logging Avanzado

### 📈 Configurar Logrotate

```bash
# Crear configuración personalizada
sudo nano /etc/logrotate.d/custom-domains

# Contenido:
/var/log/apache2/*_access.log {
    weekly
    missingok
    rotate 52
    compress
    delaycompress
    notifempty
    postrotate
        /bin/systemctl reload apache2 > /dev/null 2>&1 || true
    endscript
}

/var/log/apache2/*_error.log {
    weekly
    missingok
    rotate 52
    compress
    delaycompress
    notifempty
    postrotate
        /bin/systemctl reload apache2 > /dev/null 2>&1 || true
    endscript
}
```

### 📊 Script de Monitoreo Personalizado

```bash
# Crear script de monitoreo
nano scripts/custom_monitoring.sh

#!/bin/bash
# Script de monitoreo personalizado

# Verificar uso de disco
DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ $DISK_USAGE -gt 80 ]; then
    echo "ALERTA: Uso de disco alto: $DISK_USAGE%" | mail -s "Alerta Servidor" admin@tu-dominio.com
fi

# Verificar memoria
MEM_USAGE=$(free | awk 'NR==2{printf "%.2f", $3*100/$2 }')
if (( $(echo "$MEM_USAGE > 90" | bc -l) )); then
    echo "ALERTA: Uso de memoria alto: $MEM_USAGE%" | mail -s "Alerta Servidor" admin@tu-dominio.com
fi

# Agregar a crontab:
# */15 * * * * /path/to/scripts/custom_monitoring.sh
```

---

## 🚀 Optimización de Rendimiento

### ⚡ Configurar Cache con mod_cache

```apache
# Habilitar módulos
sudo a2enmod cache
sudo a2enmod cache_disk
sudo a2enmod expires
sudo a2enmod headers

# Agregar a tu Virtual Host:
<IfModule mod_cache.c>
    CacheEnable disk /
    CacheRoot /var/cache/apache2/mod_cache_disk
    CacheDefaultExpire 3600
    CacheMaxExpire 86400
    CacheIgnoreNoLastMod On
    CacheIgnoreCacheControl On
</IfModule>

# Configurar expiración
<IfModule mod_expires.c>
    ExpiresActive On
    ExpiresByType text/css "access plus 1 month"
    ExpiresByType application/javascript "access plus 1 month"
    ExpiresByType image/png "access plus 1 month"
    ExpiresByType image/jpg "access plus 1 month"
    ExpiresByType image/jpeg "access plus 1 month"
    ExpiresByType image/gif "access plus 1 month"
    ExpiresByType image/x-icon "access plus 1 year"
</IfModule>
```

### 🔧 Tuning de Apache

```apache
# Editar configuración principal
sudo nano /etc/apache2/apache2.conf

# Optimizaciones:
ServerTokens Prod
ServerSignature Off
KeepAlive On
MaxKeepAliveRequests 100
KeepAliveTimeout 15

# Para mpm_prefork:
<IfModule mpm_prefork_module>
    StartServers 5
    MinSpareServers 5
    MaxSpareServers 10
    MaxRequestWorkers 150
    MaxConnectionsPerChild 1000
</IfModule>
```

---

## 🔄 Backup y Recuperación

### 💾 Script de Backup Automático

```bash
# Crear script de backup
nano scripts/backup.sh

#!/bin/bash
# Script de backup completo

BACKUP_DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backup/$BACKUP_DATE"

# Crear directorio de backup
mkdir -p $BACKUP_DIR

# Backup de configuraciones
cp -r /etc/apache2/sites-available $BACKUP_DIR/
cp -r /etc/bind $BACKUP_DIR/
cp /etc/fail2ban/jail.local $BACKUP_DIR/

# Backup de sitios web
cp -r /var/www $BACKUP_DIR/

# Backup de bases de datos (si aplica)
# mysqldump --all-databases > $BACKUP_DIR/mysql_backup.sql

# Comprimir backup
tar -czf /backup/backup_$BACKUP_DATE.tar.gz $BACKUP_DIR
rm -rf $BACKUP_DIR

# Limpiar backups antiguos (mantener últimos 7 días)
find /backup -name "backup_*.tar.gz" -mtime +7 -delete

echo "Backup completado: backup_$BACKUP_DATE.tar.gz"
```

### 🔄 Cron Job para Backup Automático

```bash
# Agregar a crontab
crontab -e

# Backup diario a las 2 AM
0 2 * * * /path/to/scripts/backup.sh

# Backup semanal completo los domingos
0 1 * * 0 /path/to/scripts/full_backup.sh
```

---

## 🧪 Entorno de Testing

### 🔬 Configurar Subdominio de Testing

```bash
# Crear zona de testing
cp dns/db.tu-dominio.com dns/db.test.tu-dominio.com

# Editar para testing
nano dns/db.test.tu-dominio.com

# Cambiar registros A a IP de testing
test    IN      A       192.168.1.200  # IP de servidor de test
```

### 🎯 Virtual Host para Testing

```apache
<VirtualHost *:80>
    ServerName test.tu-dominio.com
    DocumentRoot /var/www/test.tu-dominio.com
    
    # Headers de identificación
    Header always set X-Environment "testing"
    Header always set X-Robots-Tag "noindex, nofollow"
    
    # Autenticación básica para testing
    <Directory /var/www/test.tu-dominio.com>
        AuthType Basic
        AuthName "Testing Environment"
        AuthUserFile /etc/apache2/.htpasswd-test
        Require valid-user
    </Directory>
</VirtualHost>
```

---

## 📱 Configuraciones Específicas por Tipo de Sitio

### 🛒 E-commerce

```apache
# Configuraciones adicionales para e-commerce
<Directory /var/www/tu-tienda.com>
    # Seguridad reforzada
    Options -Indexes -ExecCGI
    AllowOverride All
    
    # Headers de seguridad para e-commerce
    Header always set X-Frame-Options DENY
    Header always set X-Content-Type-Options nosniff
    Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains"
if</Directory>

# Área de administración super protegida
<Directory /var/www/tu-tienda.com/admin>
    AuthType Basic
    AuthName "Administración E-commerce"
    AuthUserFile /etc/apache2/.htpasswd-ecommerce
    Require valid-user
    
    # Solo desde IPs específicas
    Require ip 192.168.1
    
    # Headers anti-cache
    Header always set Cache-Control "no-cache, no-store, must-revalidate"
    Header always set Pragma "no-cache"
    Header always set Expires "0"
</Directory>
```

### 🏢 Portal Corporativo

```apache
# Configuraciones para portal corporativo
<Directory /var/www/portal-corporativo.com>
    Options -Indexes FollowSymLinks
    AllowOverride All
    
    # Restricción por horario laboral
    RewriteEngine On
    RewriteCond %{TIME_HOUR} <08 [OR]
    RewriteCond %{TIME_HOUR} >18
    RewriteCond %{REQUEST_URI} ^/intranet
    RewriteRule ^(.*)$ /maintenance.html [L]
</Directory>

# Diferentes niveles de acceso
<Directory /var/www/portal-corporativo.com/rrhh>
    AuthType Basic
    AuthName "Recursos Humanos"
    AuthUserFile /etc/apache2/.htpasswd-rrhh
    Require valid-user
</Directory>

<Directory /var/www/portal-corporativo.com/finanzas>
    AuthType Basic
    AuthName "Área Financiera"
    AuthUserFile /etc/apache2/.htpasswd-finanzas
    Require valid-user
    
    # Extra seguridad para finanzas
    SSLRequireSSL
    Header always set X-Frame-Options DENY
</Directory>
```

---

**📚 Esta guía cubre configuraciones avanzadas. Para configuraciones básicas, consulta [INSTALLATION.md](INSTALLATION.md).**