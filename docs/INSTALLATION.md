# 🚀 Guía de Instalación Completa

## 📋 Requisitos del Sistema

### 🖥️ Hardware Mínimo
- **CPU**: 2 cores / 2 GHz
- **RAM**: 2 GB mínimo, 4 GB recomendado
- **Almacenamiento**: 20 GB de espacio libre
- **Red**: Conexión a internet estable

### 💻 Software Requerido
- **Ubuntu Server**: 20.04 LTS o superior
- **Acceso root**: Para instalación de paquetes
- **Git**: Para clonar el repositorio

---

## ⚡ Instalación Rápida (Recomendada)

### 1. Preparar el Servidor
```bash
# Actualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar Git
sudo apt install -y git
```

### 2. Clonar el Repositorio
```bash
# Clonar desde GitHub
git clone https://github.com/hackhit/conf-serv-dev.git
cd conf-serv-dev

# Verificar archivos
ls -la
```

### 3. Ejecutar Instalación Automática
```bash
# Hacer ejecutables los scripts
chmod +x scripts/*.sh

# Ejecutar configuración completa
sudo ./scripts/deploy_server.sh
```

### 4. Configurar DNS Externos
En tu proveedor de dominios, crear estos registros:
```dns
tallerchevrolet.com      A    38.10.252.121
www.tallerchevrolet.com  A    38.10.252.121
repuestoschevy.com       A    38.10.252.121
www.repuestoschevy.com   A    38.10.252.121
deosvenezuela.com        A    38.10.252.121
www.deosvenezuela.com    A    38.10.252.121
```

### 5. Configurar SSL
```bash
# Esperar 15 minutos después de configurar DNS
sudo ./scripts/ssl_setup.sh
```

### 6. Verificar Instalación
```bash
# Ejecutar verificación completa
sudo ./scripts/server_check.sh
```

---

## 🔧 Instalación Manual Detallada

### Paso 1: Configuración de Red

```bash
# Detectar interfaz de red
ip link show

# Editar configuración (cambiar ens18 por tu interfaz)
sudo nano network/01-network-config.yaml

# Aplicar configuración
sudo cp network/01-network-config.yaml /etc/netplan/
sudo netplan apply
```

### Paso 2: Instalación de Paquetes

```bash
# Actualizar repositorios
sudo apt update

# Instalar paquetes necesarios
sudo apt install -y \
    apache2 \
    bind9 \
    bind9utils \
    bind9-doc \
    ufw \
    fail2ban \
    certbot \
    python3-certbot-apache \
    htop \
    curl \
    wget \
    git
```

### Paso 3: Configuración de Firewall

```bash
# Configurar UFW
sudo ufw allow OpenSSH
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 53/tcp
sudo ufw allow 53/udp
sudo ufw --force enable

# Verificar estado
sudo ufw status
```

### Paso 4: Configuración de BIND9

```bash
# Copiar configuraciones DNS
sudo cp dns/named.conf.local /etc/bind/
sudo cp dns/db.* /etc/bind/

# Verificar configuración
sudo named-checkconf
sudo named-checkzone tallerchevrolet.com /etc/bind/db.tallerchevrolet.com
sudo named-checkzone repuestoschevy.com /etc/bind/db.repuestoschevy.com
sudo named-checkzone deosvenezuela.com /etc/bind/db.deosvenezuela.com

# Reiniciar servicio
sudo systemctl restart bind9
sudo systemctl enable bind9
```

### Paso 5: Configuración de Apache

```bash
# Habilitar módulos
sudo a2enmod rewrite ssl headers expires deflate

# Copiar Virtual Hosts
sudo cp apache/*.conf /etc/apache2/sites-available/

# Habilitar sitios
sudo a2ensite tallerchevrolet.com.conf
sudo a2ensite repuestoschevy.com.conf
sudo a2ensite deosvenezuela.com.conf
sudo a2dissite 000-default.conf

# Crear directorios web
sudo mkdir -p /var/www/tallerchevrolet.com
sudo mkdir -p /var/www/repuestoschevy.com
sudo mkdir -p /var/www/deosvenezuela.com

# Establecer permisos
sudo chown -R www-data:www-data /var/www/
sudo chmod -R 755 /var/www/

# Verificar configuración
sudo apache2ctl configtest

# Reiniciar Apache
sudo systemctl restart apache2
sudo systemctl enable apache2
```

### Paso 6: Configuración de Fail2Ban

```bash
# Copiar configuración
sudo cp security/fail2ban.conf /etc/fail2ban/jail.local

# Reiniciar servicio
sudo systemctl restart fail2ban
sudo systemctl enable fail2ban

# Verificar estado
sudo fail2ban-client status
```

---

## 🔐 Configuración SSL (Let's Encrypt)

### Requisitos Previos
- DNS configurado correctamente
- Dominios resolviendo a la IP del servidor
- Apache funcionando correctamente

### Proceso Automático
```bash
# Ejecutar script SSL
sudo ./scripts/ssl_setup.sh
```

### Proceso Manual
```bash
# Instalar Certbot (si no está instalado)
sudo apt install -y certbot python3-certbot-apache

# Obtener certificados para cada dominio
sudo certbot --apache -d tallerchevrolet.com -d www.tallerchevrolet.com
sudo certbot --apache -d repuestoschevy.com -d www.repuestoschevy.com
sudo certbot --apache -d deosvenezuela.com -d www.deosvenezuela.com

# Configurar renovación automática
echo "0 12 * * * /usr/bin/certbot renew --quiet && /usr/bin/systemctl reload apache2" | sudo crontab -
```

---

## 🔍 Verificación de la Instalación

### Tests Básicos
```bash
# Verificar servicios
sudo systemctl status apache2
sudo systemctl status bind9
sudo systemctl status fail2ban

# Verificar puertos
sudo netstat -tulnp | grep :80
sudo netstat -tulnp | grep :443
sudo netstat -tulnp | grep :53

# Verificar DNS local
nslookup tallerchevrolet.com localhost
nslookup repuestoschevy.com localhost
nslookup deosvenezuela.com localhost
```

### Tests Web
```bash
# Verificar sitios HTTP
curl -I http://tallerchevrolet.com
curl -I http://repuestoschevy.com
curl -I http://deosvenezuela.com

# Verificar sitios HTTPS (después de SSL)
curl -I https://tallerchevrolet.com
curl -I https://repuestoschevy.com
curl -I https://deosvenezuela.com
```

### Script de Verificación Completa
```bash
# Ejecutar verificación automática
sudo ./scripts/server_check.sh
```

---

## 🚑 Solución de Problemas

### Error: DNS no resuelve
```bash
# Verificar configuración BIND9
sudo named-checkconf
sudo systemctl status bind9

# Revisar logs
sudo tail -f /var/log/syslog | grep named
```

### Error: Apache no inicia
```bash
# Verificar configuración
sudo apache2ctl configtest

# Revisar logs
sudo tail -f /var/log/apache2/error.log
```

### Error: SSL no funciona
```bash
# Verificar certificados
sudo certbot certificates

# Renovar manualmente
sudo certbot renew
```

### Error: Puerto ocupado
```bash
# Verificar qué proceso usa el puerto
sudo lsof -i :80
sudo lsof -i :443
sudo lsof -i :53
```

---

## 📝 Configuraciones Adicionales

### Cambiar IPs del Proyecto
Si necesitas usar IPs diferentes, edita estos archivos:
- `network/01-network-config.yaml`
- `dns/db.*.com`
- `scripts/deploy_server.sh`
- `scripts/ssl_setup.sh`

### Agregar Nuevos Dominios
1. Crear nueva zona DNS en `dns/`
2. Agregar configuración en `dns/named.conf.local`
3. Crear Virtual Host en `apache/`
4. Actualizar scripts si es necesario

### Configurar Correo Electrónico
Para habilitar correo electrónico:
```bash
# Instalar Postfix
sudo apt install -y postfix

# Configurar como satellite system
sudo dpkg-reconfigure postfix
```

---

## ✅ Checklist de Instalación

- [ ] Ubuntu Server instalado y actualizado
- [ ] Repositorio clonado
- [ ] Scripts ejecutables
- [ ] Script principal ejecutado
- [ ] Servicios funcionando (Apache, BIND9, Fail2Ban)
- [ ] Firewall configurado
- [ ] DNS externos configurados
- [ ] SSL configurado
- [ ] Sitios web accesibles
- [ ] Verificación completada

---

**✅ ¡Instalación Completada!**

Tu servidor Ubuntu está listo para producción con hosting multi-dominio, DNS autoritativo y seguridad avanzada.