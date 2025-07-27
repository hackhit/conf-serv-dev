# 🚑 Guía de Solución de Problemas

## 🔍 Diagnóstico General

### Script de Verificación Automática
```bash
# Ejecutar diagnóstico completo
sudo ./scripts/server_check.sh
```

Este script verificará:
- Estado de todos los servicios
- Puertos abiertos
- Conectividad web
- Información del sistema
- Estado de Fail2Ban
- Certificados SSL

---

## 🔥 Problemas de Firewall

### ❌ Problema: Puertos Bloqueados

**Síntomas:**
- Sitios web no accesibles desde internet
- Conexión rechazada
- Timeouts de conexión

**Solución:**
```bash
# Verificar estado del firewall
sudo ufw status verbose

# Abrir puertos necesarios
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 53/tcp
sudo ufw allow 53/udp
sudo ufw allow 22/tcp

# Recargar firewall
sudo ufw reload
```

### ❌ Problema: UFW No Configurado

**Solución:**
```bash
# Habilitar UFW
sudo ufw --force enable

# Configurar reglas básicas
sudo ufw default deny incoming
sudo ufw default allow outgoing
```

---

## 🌐 Problemas de Apache

### ❌ Problema: Apache No Inicia

**Síntomas:**
- Error al iniciar Apache
- Puertos 80/443 no escuchan
- Sitios web no responden

**Diagnóstico:**
```bash
# Verificar estado de Apache
sudo systemctl status apache2

# Verificar configuración
sudo apache2ctl configtest

# Ver logs de error
sudo tail -f /var/log/apache2/error.log
```

**Soluciones Comunes:**

1. **Error de Configuración:**
```bash
# Verificar sintaxis
sudo apache2ctl configtest

# Corregir errores en configuración
sudo nano /etc/apache2/sites-available/sitio.conf
```

2. **Puerto Ocupado:**
```bash
# Verificar qué proceso usa el puerto 80
sudo lsof -i :80

# Detener proceso conflictivo
sudo systemctl stop nginx  # si existe
```

3. **Módulos Faltantes:**
```bash
# Habilitar módulos necesarios
sudo a2enmod rewrite ssl headers
sudo systemctl restart apache2
```

### ❌ Problema: Virtual Hosts No Funcionan

**Solución:**
```bash
# Verificar sitios habilitados
sudo a2ensite tallerchevrolet.com.conf
sudo a2ensite repuestoschevy.com.conf
sudo a2ensite deosvenezuela.com.conf

# Deshabilitar sitio por defecto
sudo a2dissite 000-default.conf

# Recargar configuración
sudo systemctl reload apache2
```

### ❌ Problema: Permisos de Archivos

**Solución:**
```bash
# Establecer propietario correcto
sudo chown -R www-data:www-data /var/www/

# Establecer permisos correctos
sudo chmod -R 755 /var/www/
sudo chmod -R 644 /var/www/*/index.html
```

---

## 🔍 Problemas de DNS (BIND9)

### ❌ Problema: DNS No Resuelve

**Síntomas:**
- Dominios no resuelven localmente
- nslookup falla
- Sitios no accesibles por dominio

**Diagnóstico:**
```bash
# Verificar estado de BIND9
sudo systemctl status bind9

# Verificar configuración
sudo named-checkconf

# Verificar zonas
sudo named-checkzone tallerchevrolet.com /etc/bind/db.tallerchevrolet.com

# Ver logs
sudo tail -f /var/log/syslog | grep named
```

**Soluciones:**

1. **Error de Configuración:**
```bash
# Verificar sintaxis
sudo named-checkconf

# Corregir errores en configuración
sudo nano /etc/bind/named.conf.local
```

2. **Error en Zona DNS:**
```bash
# Verificar zona específica
sudo named-checkzone tallerchevrolet.com /etc/bind/db.tallerchevrolet.com

# Incrementar serial en zona
sudo nano /etc/bind/db.tallerchevrolet.com
# Cambiar: 2024072601 -> 2024072602
```

3. **Puerto 53 Ocupado:**
```bash
# Verificar qué usa el puerto 53
sudo lsof -i :53

# Detener systemd-resolved si interfiere
sudo systemctl disable systemd-resolved
sudo systemctl stop systemd-resolved
```

### ❌ Problema: DNS Externo No Configurado

**Síntomas:**
- DNS funciona localmente pero no desde internet
- Dominios no resuelven desde otros lugares

**Solución:**
Configurar en tu proveedor de dominios:
```dns
tallerchevrolet.com      A    38.10.252.121
www.tallerchevrolet.com  A    38.10.252.121
repuestoschevy.com       A    38.10.252.121
www.repuestoschevy.com   A    38.10.252.121
deosvenezuela.com        A    38.10.252.121
www.deosvenezuela.com    A    38.10.252.121
```

---

## 🔐 Problemas de SSL

### ❌ Problema: Certificados SSL No Se Crean

**Síntomas:**
- Error al ejecutar Certbot
- HTTPS no funciona
- Advertencias de seguridad en navegador

**Diagnóstico:**
```bash
# Verificar Certbot
certbot --version

# Ver certificados existentes
sudo certbot certificates

# Probar renovación
sudo certbot renew --dry-run
```

**Soluciones:**

1. **DNS No Resuelve Correctamente:**
```bash
# Verificar resolución DNS
nslookup tallerchevrolet.com 8.8.8.8

# Esperar propagación DNS (15-30 minutos)
# Intentar nuevamente
sudo ./scripts/ssl_setup.sh
```

2. **Apache No Responde:**
```bash
# Verificar que el sitio responda
curl -I http://tallerchevrolet.com

# Verificar Virtual Host
sudo apache2ctl -S
```

3. **Límite de Intentos Alcanzado:**
```bash
# Esperar 1 hora antes de reintentar
# Let's Encrypt tiene límites por hora

# Usar --staging para pruebas
sudo certbot --apache --staging -d tallerchevrolet.com
```

### ❌ Problema: Certificados Expirados

**Solución:**
```bash
# Renovar manualmente
sudo certbot renew

# Verificar cron job
sudo crontab -l | grep certbot

# Agregar cron job si no existe
echo "0 12 * * * /usr/bin/certbot renew --quiet && /usr/bin/systemctl reload apache2" | sudo crontab -
```

---

## 🛡️ Problemas de Fail2Ban

### ❌ Problema: Fail2Ban No Protege

**Diagnóstico:**
```bash
# Verificar estado
sudo fail2ban-client status

# Ver reglas activas
sudo fail2ban-client status apache-auth

# Ver logs
sudo tail -f /var/log/fail2ban.log
```

**Soluciones:**

1. **Configuración Incorrecta:**
```bash
# Verificar configuración
sudo fail2ban-client -d

# Recargar configuración
sudo fail2ban-client reload
```

2. **Logs No Encontrados:**
```bash
# Verificar rutas de logs
ls -la /var/log/apache2/
ls -la /var/log/auth.log

# Ajustar rutas en configuración
sudo nano /etc/fail2ban/jail.local
```

### ❌ Problema: IP Bloqueada Incorrectamente

**Solución:**
```bash
# Desbloquear IP específica
sudo fail2ban-client set apache-auth unbanip 192.168.1.100

# Agregar IP a lista blanca
sudo nano /etc/fail2ban/jail.local
# Agregar a ignoreip: 192.168.1.0/24

# Recargar configuración
sudo fail2ban-client reload
```

---

## 🌐 Problemas de Red

### ❌ Problema: IP Estática No Funciona

**Diagnóstico:**
```bash
# Verificar configuración de red
ip addr show
ip route show

# Verificar netplan
sudo netplan --debug apply
```

**Solución:**
```bash
# Verificar interfaz de red correcta
ip link show

# Editar configuración
sudo nano /etc/netplan/01-network-config.yaml

# Aplicar cambios
sudo netplan apply
```

### ❌ Problema: Sin Conectividad a Internet

**Solución:**
```bash
# Verificar gateway
ip route show

# Verificar DNS
nslookup google.com

# Reiniciar networking
sudo systemctl restart systemd-networkd
```

---

## 💾 Problemas de Rendimiento

### ❌ Problema: Servidor Lento

**Diagnóstico:**
```bash
# Verificar uso de recursos
htop
free -h
df -h
iostat
```

**Soluciones:**

1. **Memoria Insuficiente:**
```bash
# Crear swap si no existe
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Hacer permanente
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

2. **Disco Lleno:**
```bash
# Limpiar logs antiguos
sudo journalctl --vacuum-time=7d
sudo find /var/log -name "*.log" -type f -mtime +30 -delete

# Limpiar cache de paquetes
sudo apt autoremove
sudo apt autoclean
```

---

## 🔧 Comandos Útiles para Diagnóstico

### Verificación de Servicios
```bash
# Estado de todos los servicios
sudo systemctl status apache2 bind9 fail2ban ssh

# Logs en tiempo real
sudo journalctl -f

# Logs de servicio específico
sudo journalctl -u apache2 -f
```

### Verificación de Red
```bash
# Puertos abiertos
sudo netstat -tulnp
sudo ss -tulnp

# Conexiones activas
sudo netstat -an | grep ESTABLISHED

# Test de conectividad
ping -c 4 google.com
curl -I http://tallerchevrolet.com
```

### Verificación de Recursos
```bash
# Uso de CPU y memoria
top
htop
free -h

# Uso de disco
df -h
du -sh /var/www/*

# Procesos que más consumen
ps aux --sort=-%cpu | head -10
ps aux --sort=-%mem | head -10
```

---

## 📞 Obtener Ayuda

### Logs Importantes
```bash
# Apache
/var/log/apache2/error.log
/var/log/apache2/access.log

# DNS
/var/log/syslog (grep named)

# Fail2Ban
/var/log/fail2ban.log

# Sistema
/var/log/syslog
sudo journalctl -xe
```

### Crear Reporte de Error
```bash
# Ejecutar diagnóstico completo
sudo ./scripts/server_check.sh > server_report.txt

# Agregar logs relevantes
sudo tail -50 /var/log/apache2/error.log >> server_report.txt
sudo tail -50 /var/log/syslog | grep named >> server_report.txt
```

### Contacto para Soporte
- **GitHub Issues**: [https://github.com/hackhit/conf-serv-dev/issues](https://github.com/hackhit/conf-serv-dev/issues)
- **Email**: contacto@hackhit.dev

---

**✅ Recuerda**: Siempre hacer backup de configuraciones antes de hacer cambios importantes.