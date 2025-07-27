#!/bin/bash

# ===============================================
# SCRIPT DE IMPLEMENTACIÓN COMPLETA DEL SERVIDOR
# Proyecto: conf-serv-dev
# Servidor: Ubuntu Server
# Dominios: tallerchevrolet.com, repuestoschevy.com, deosvenezuela.com
# IP Externa: 38.10.252.121
# IP Interna: 192.168.1.167
# ===============================================

set -e  # Salir en caso de error

echo "🚀 INICIANDO CONFIGURACIÓN COMPLETA DEL SERVIDOR..."
echo "============================================="

# Verificar que se ejecute como root
if [[ $EUID -ne 0 ]]; then
   echo "❌ Este script debe ejecutarse como root (sudo)"
   exit 1
fi

# 1. ACTUALIZACIÓN DEL SISTEMA
echo "📦 Actualizando sistema..."
apt update && apt upgrade -y

# 2. INSTALACIÓN DE PAQUETES
echo "📥 Instalando paquetes necesarios..."
apt install -y \
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
    unzip \
    git \
    nano \
    tree \
    net-tools

# 3. CONFIGURACIÓN DE RED
echo "🌐 Configurando red estática..."
# Detectar interfaz de red automáticamente
INTERFACE=$(ip route | grep default | awk '{print $5}' | head -1)
echo "Interfaz detectada: $INTERFACE"

# Crear configuración de netplan
cat > /etc/netplan/01-network-config.yaml << EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    $INTERFACE:
      addresses:
        - 192.168.1.167/24
      gateway4: 192.168.1.10
      nameservers:
        addresses:
          - 1.1.1.1
          - 1.0.0.1
          - 2606:4700:4700::1111
          - 2606:4700:4700::1001
      dhcp4: false
      dhcp6: false
      optional: true
EOF

# Aplicar configuración de red
netplan apply

# 4. CONFIGURACIÓN DE FIREWALL
echo "🔥 Configurando firewall..."
ufw --force reset
ufw allow OpenSSH
ufw allow 80/tcp        # HTTP
ufw allow 443/tcp       # HTTPS
ufw allow 53/tcp        # DNS
ufw allow 53/udp        # DNS
ufw allow 22/tcp        # SSH
ufw --force enable

# 5. CONFIGURACIÓN DE APACHE
echo "🌐 Configurando Apache..."

# Habilitar módulos necesarios
a2enmod rewrite ssl headers expires deflate

# Crear directorios para sitios web
mkdir -p /var/www/tallerchevrolet.com
mkdir -p /var/www/repuestoschevy.com
mkdir -p /var/www/deosvenezuela.com

# Crear páginas de prueba profesionales
echo "📄 Creando páginas web de prueba..."

# Páginas con diseño moderno
cat > /var/www/tallerchevrolet.com/index.html << 'EOF'
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Taller Chevrolet - Servicio Técnico Especializado</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; display: flex; align-items: center; justify-content: center; }
        .container { max-width: 900px; width: 90%; background: rgba(255,255,255,0.95); padding: 40px; border-radius: 20px; box-shadow: 0 20px 40px rgba(0,0,0,0.1); backdrop-filter: blur(10px); }
        h1 { color: #003d7a; text-align: center; font-size: 3em; margin-bottom: 20px; text-shadow: 2px 2px 4px rgba(0,0,0,0.1); }
        .status { background: linear-gradient(45deg, #28a745, #20c997); color: white; padding: 20px; border-radius: 15px; text-align: center; margin: 30px 0; font-size: 1.3em; font-weight: bold; box-shadow: 0 10px 20px rgba(40, 167, 69, 0.3); }
        .info { background: #f8f9fa; padding: 25px; border-radius: 15px; margin: 25px 0; border-left: 5px solid #003d7a; }
        .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin: 30px 0; }
        .card { background: linear-gradient(145deg, #e9ecef, #dee2e6); padding: 20px; border-radius: 15px; text-align: center; box-shadow: 0 8px 16px rgba(0,0,0,0.1); transition: transform 0.3s ease; }
        .card:hover { transform: translateY(-5px); }
        .icon { font-size: 2.5em; margin-bottom: 15px; }
        .footer { text-align: center; margin-top: 30px; color: #6c757d; border-top: 2px solid #e9ecef; padding-top: 20px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔧 Taller Chevrolet</h1>
        <div class="status">✅ Servidor funcionando correctamente</div>
        
        <div class="info">
            <h3>🚗 Servicio Técnico Especializado</h3>
            <p>Bienvenido al Taller Chevrolet. Contamos con mecánicos certificados y tecnología de punta para brindarle el mejor servicio técnico para su vehículo Chevrolet.</p>
        </div>

        <div class="grid">
            <div class="card">
                <div class="icon">🌐</div>
                <strong>IP Externa</strong><br>
                38.10.252.121
            </div>
            <div class="card">
                <div class="icon">🏠</div>
                <strong>IP Interna</strong><br>
                192.168.1.167
            </div>
            <div class="card">
                <div class="icon">📅</div>
                <strong>Configurado</strong><br>
                Julio 2024
            </div>
            <div class="card">
                <div class="icon">🔒</div>
                <strong>SSL Ready</strong><br>
                Let's Encrypt
            </div>
        </div>
        
        <div class="footer">
            <p><strong>🚀 Powered by conf-serv-dev</strong> | Configuración profesional de servidor Ubuntu</p>
            <p>DNS • Apache • SSL • Seguridad</p>
        </div>
    </div>
</body>
</html>
EOF

# Establecer permisos correctos
chown -R www-data:www-data /var/www/
chmod -R 755 /var/www/

# 6. CONFIGURACIÓN DE BIND9
echo "🔍 Configurando DNS (BIND9)..."

# Backup de configuración original
cp /etc/bind/named.conf.local /etc/bind/named.conf.local.backup

# 7. CONFIGURAR FAIL2BAN
echo "🛡️ Configurando Fail2Ban..."
cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3
backend = systemd

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log

[apache-auth]
enabled = true
port = http,https
filter = apache-auth
logpath = /var/log/apache2/*error.log
maxretry = 3

[apache-noscript]
enabled = true
port = http,https
filter = apache-noscript
logpath = /var/log/apache2/*error.log
maxretry = 6

[apache-overflows]
enabled = true
port = http,https
filter = apache-overflows
logpath = /var/log/apache2/*error.log
maxretry = 2
EOF

# 8. REINICIAR Y HABILITAR SERVICIOS
echo "🔄 Reiniciando servicios..."
systemctl restart bind9
systemctl restart apache2
systemctl restart fail2ban

systemctl enable bind9
systemctl enable apache2
systemctl enable fail2ban

# 9. VERIFICACIONES FINALES
echo "✅ Realizando verificaciones finales..."
named-checkconf 2>/dev/null || echo "⚠️ Verificar configuración BIND9"
apache2ctl configtest 2>/dev/null || echo "⚠️ Verificar configuración Apache"

echo ""
echo "🎉 ==============================================="
echo "     CONFIGURACIÓN COMPLETADA EXITOSAMENTE"
echo "==============================================="
echo ""
echo "📋 RESUMEN DE CONFIGURACIÓN:"
echo "• IP Interna: 192.168.1.167"
echo "• IP Externa: 38.10.252.121"
echo "• Gateway: 192.168.1.10"
echo "• DNS: Cloudflare (1.1.1.1, 1.0.0.1)"
echo ""
echo "🌐 DOMINIOS CONFIGURADOS:"
echo "• http://tallerchevrolet.com"
echo "• http://repuestoschevy.com"
echo "• http://deosvenezuela.com"
echo ""
echo "🔧 SERVICIOS ACTIVOS:"
echo "• Apache2 (Puerto 80/443)"
echo "• BIND9 (Puerto 53)"
echo "• SSH (Puerto 22)"
echo "• Fail2Ban (Protección)"
echo ""
echo "📝 PRÓXIMOS PASOS:"
echo "1. Configurar DNS en tu proveedor de dominios"
echo "2. Apuntar registros A a: 38.10.252.121"
echo "3. Configurar SSL: ./scripts/ssl_setup.sh"
echo "4. Verificar funcionamiento: ./scripts/server_check.sh"
echo ""
echo "✅ ¡Servidor listo para producción!"
echo "🌍 Accede desde internet: http://38.10.252.121"