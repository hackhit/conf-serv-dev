# 🚀 Configurador de Servidor

<div align="center">

![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)
![Apache](https://img.shields.io/badge/Apache-D22128?style=for-the-badge&logo=apache&logoColor=white)
![BIND9](https://img.shields.io/badge/BIND9-0052CC?style=for-the-badge&logo=dns&logoColor=white)
![Let's Encrypt](https://img.shields.io/badge/Let's%20Encrypt-003A70?style=for-the-badge&logo=letsencrypt&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)

**🌐 Configuración Completa de Servidor Ubuntu para Hosting Multi-Dominio**

*Apache • BIND9 • SSL/TLS • Seguridad Avanzada • Automatización*

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub stars](https://img.shields.io/github/stars/hackhit/conf-serv-dev?style=social)](https://github.com/hackhit/conf-serv-dev/stargazers)
[![GitHub issues](https://img.shields.io/github/issues/hackhit/conf-serv-dev)](https://github.com/hackhit/conf-serv-dev/issues)
[![GitHub forks](https://img.shields.io/github/forks/hackhit/conf-serv-dev?style=social)](https://github.com/hackhit/conf-serv-dev/network/members)

</div>

---

## 📋 Descripción del Proyecto

**Configurador de Servidor** es una solución completa y automatizada para configurar un servidor Ubuntu con capacidades de hosting profesional. Este proyecto incluye configuración de DNS propio, servidor web con múltiples dominios, certificados SSL automáticos y seguridad avanzada. Es el resultado de años de practica y puesta en marcha de muchisimos servidores, aqui mi aporte, y si pierdes informacion en tu PC, aqui lo vas a encontrar cada vez que lo requieras.

### 🎯 **Casos de Uso**
- Hosting de múltiples sitios web en un solo servidor
- Configuración de DNS autoritativo propio
- Implementación de SSL/TLS automático
- Servidor de desarrollo y producción
- Infraestructura web escalable

---

## ✨ Características Principales

### 🌐 **Servidor Web Completo**
- **Apache 2.4** con Virtual Hosts configurados
- Soporte para múltiples dominios simultáneos
- Configuración optimizada para rendimiento
- Headers de seguridad implementados
- Compresión GZIP habilitada

### 🔍 **DNS Autoritativo Propio**
- **BIND9** completamente configurado
- Zonas DNS para múltiples dominios
- Resolución directa e inversa
- Configuración redundante de nameservers

### 🔐 **Seguridad Avanzada**
- **Let's Encrypt** SSL/TLS automático
- **Fail2Ban** contra ataques de fuerza bruta
- Firewall **UFW** configurado
- Headers de seguridad HTTP
- Autenticación básica para áreas administrativas

### 🤖 **Automatización Completa**
- Script de implementación de un solo comando
- Configuración SSL automática
- Monitoreo y verificación integrados
- Renovación automática de certificados

---

## 🌍 Dominios de Ejemplo Configurados

| Dominio | Propósito | Características |
|---------|-----------|----------------|
| **tallerchevrolet.com** | Taller mecánico | Sitio corporativo, área admin |
| **repuestoschevy.com** | E-commerce | Tienda online, inventario, pagos |
| **deosvenezuela.com** | Portal corporativo | Intranet, RRHH, finanzas |

---

## 🚀 Implementación Rápida

### ⚡ **Implementación Automática (1 Comando)**

```bash
# 1. Clonar el repositorio
git clone https://github.com/hackhit/conf-serv-dev.git
cd conf-serv-dev

# 2. Hacer ejecutables los scripts
chmod +x scripts/*.sh

# 3. Ejecutar configuración completa
sudo ./scripts/deploy_server.sh
```

### 🔧 **Configuración Manual Detallada**

<details>
<summary>Ver pasos manuales</summary>

#### 1. Configurar Red Estática
```bash
sudo cp network/01-network-config.yaml /etc/netplan/
sudo netplan apply
```

#### 2. Configurar BIND9 (DNS)
```bash
sudo cp dns/named.conf.local /etc/bind/
sudo cp dns/db.* /etc/bind/
sudo systemctl restart bind9
```

#### 3. Configurar Apache
```bash
sudo cp apache/*.conf /etc/apache2/sites-available/
sudo a2ensite tallerchevrolet.com.conf
sudo a2ensite repuestoschevy.com.conf
sudo a2ensite deosvenezuela.com.conf
sudo systemctl restart apache2
```

#### 4. Configurar Seguridad
```bash
sudo cp security/fail2ban.conf /etc/fail2ban/jail.local
sudo systemctl restart fail2ban
```

</details>

---

## 📁 Estructura del Proyecto

```
conf-serv-dev/
├── 📜 README.md                      # Documentación principal
├── 📜 LICENSE                        # Licencia MIT
├── 📜 CHANGELOG.md                   # Historial de cambios
│
├── 🚀 scripts/
│   ├── deploy_server.sh              # 🔥 Script principal de implementación
│   ├── ssl_setup.sh                  # 🔐 Configuración SSL automática
│   └── server_check.sh               # 📊 Verificación y monitoreo
│
├── 🌐 network/
│   └── 01-network-config.yaml        # Configuración de red estática
│
├── 🔍 dns/
│   ├── named.conf.local              # Configuración principal BIND9
│   ├── db.tallerchevrolet.com        # Zona DNS Taller Chevrolet
│   ├── db.repuestoschevy.com         # Zona DNS Repuestos Chevy
│   ├── db.deosvenezuela.com          # Zona DNS Deos Venezuela
│   └── db.192                        # Zona de resolución reversa
│
├── 🌍 apache/
│   ├── tallerchevrolet.com.conf      # Virtual Host Taller
│   ├── repuestoschevy.com.conf       # Virtual Host Repuestos
│   └── deosvenezuela.com.conf        # Virtual Host Corporativo
│
├── 🛡️ security/
│   └── fail2ban.conf                 # Configuración anti-ataques
│
├── 📖 docs/
│   ├── INSTALLATION.md              # Guía de instalación detallada
│   ├── CONFIGURATION.md             # Configuración avanzada
│   ├── TROUBLESHOOTING.md           # Solución de problemas
│   └── API.md                       # Documentación de APIs
│
└── 🔧 examples/
    ├── website-templates/            # Plantillas de sitios web
    └── additional-domains/           # Configuraciones de ejemplo
```

---

## ⚙️ Configuración Técnica

### 🖥️ **Especificaciones del Servidor**
| Componente | Configuración |
|------------|---------------|
| **SO** | Ubuntu Server 20.04+ |
| **IP Interna** | 192.168.1.167/24 |
| **IP Externa** | 38.10.252.121 |
| **Gateway** | 192.168.1.10 |
| **DNS** | Cloudflare (1.1.1.1, 1.0.0.1) |

### 🔧 **Servicios Configurados**
| Servicio | Puerto | Estado | Descripción |
|----------|--------|--------|--------------
| **Apache** | 80, 443 | ✅ Activo | Servidor web con SSL |
| **BIND9** | 53 | ✅ Activo | Servidor DNS autoritativo |
| **SSH** | 22 | ✅ Activo | Acceso remoto seguro |
| **Fail2Ban** | - | ✅ Activo | Protección anti-ataques |

---

## 🔐 Configuración de Seguridad

### 🛡️ **Medidas Implementadas**
- **Firewall UFW** con reglas estrictas
- **Fail2Ban** configurado para SSH y Apache
- **Headers de seguridad** HTTP implementados
- **SSL/TLS** con certificados Let's Encrypt
- **Autenticación básica** para áreas administrativas
- **Logs detallados** de todos los servicios

### 🔒 **Configuración SSL**
```bash
# Configurar SSL para todos los dominios
sudo ./scripts/ssl_setup.sh

# Verificar certificados
sudo certbot certificates

# Renovación automática configurada via cron
```

---

## 📊 Monitoreo y Mantenimiento

### 🔍 **Verificación del Sistema**
```bash
# Ejecutar verificación completa
sudo ./scripts/server_check.sh

# Verificar servicios individuales
sudo systemctl status apache2
sudo systemctl status bind9
sudo systemctl status fail2ban
```

### 📈 **Logs y Análisis**
```bash
# Logs de Apache en tiempo real
sudo tail -f /var/log/apache2/error.log

# Logs de DNS
sudo tail -f /var/log/syslog | grep named

# Estado de Fail2Ban
sudo fail2ban-client status
```

---

## 🌐 Configuración DNS Externa

Para que los dominios sean accesibles desde internet, configura estos registros en tu proveedor de DNS:

```dns
# Registros A principales
tallerchevrolet.com      A    38.10.252.121
www.tallerchevrolet.com  A    38.10.252.121
repuestoschevy.com       A    38.10.252.121
www.repuestoschevy.com   A    38.10.252.121
deosvenezuela.com        A    38.10.252.121
www.deosvenezuela.com    A    38.10.252.121

# Registros de nameservers (opcional)
ns1.tallerchevrolet.com  A    38.10.252.121
ns2.tallerchevrolet.com  A    38.10.252.121
```

---

## 🚨 Solución de Problemas

### ❌ **Problemas Comunes**

<details>
<summary>🔍 DNS no resuelve correctamente</summary>

```bash
# Verificar configuración BIND9
sudo named-checkconf
sudo named-checkzone example.com /etc/bind/db.example.com

# Reiniciar servicio
sudo systemctl restart bind9

# Verificar logs
sudo tail -f /var/log/syslog | grep named
```
</details>

<details>
<summary>🌐 Apache no inicia</summary>

```bash
# Verificar configuración
sudo apache2ctl configtest

# Ver estado detallado
sudo systemctl status apache2

# Verificar logs
sudo tail -f /var/log/apache2/error.log
```
</details>

<details>
<summary>🔐 SSL no funciona</summary>

```bash
# Verificar certificados
sudo certbot certificates

# Renovar manualmente
sudo certbot renew

# Reconfigurar SSL
sudo ./scripts/ssl_setup.sh
```
</details>

---

## 🤝 Contribuciones

¡Las contribuciones son bienvenidas! Por favor:

1. 🍴 **Fork** el proyecto
2. 🔧 Crea una **feature branch** (`git checkout -b feature/amazing-feature`)
3. 💾 **Commit** tus cambios (`git commit -m 'Add amazing feature'`)
4. 📤 **Push** a la branch (`git push origin feature/amazing-feature`)
5. 🔄 Abre un **Pull Request**

### 📋 **Guidelines de Contribución**
- Seguir el estilo de código existente
- Incluir documentación para nuevas características
- Agregar tests cuando sea apropiado
- Mantener compatibilidad con Ubuntu 20.04+

---

## 📄 Licencia

Este proyecto está licenciado bajo la **Licencia MIT** - ver el archivo [LICENSE](LICENSE) para más detalles.

---

## 👨‍💻 Autor

**HackHit** - *Desarrollador Full-Stack & DevOps Engineer*

- 🌐 **GitHub**: [@hackhit](https://github.com/hackhit)
- 📧 **Email**: [83knmujyb@mozmail.com](mailto:83knmujyb@mozmail.com)
- 💼 **LinkedIn**: [hackhit-dev](https://linkedin.com/in/hackhit)
- 🐦 **X**: [@hackhit](https://twitter.com/hackhit)

---

## 🙏 Agradecimientos

- **Ubuntu Community** por la excelente documentación
- **Apache Software Foundation** por el servidor web más usado del mundo
- **Let's Encrypt** por SSL gratuito para todos
- **BIND** por el software DNS más confiable

---

## ⭐ ¿Te gusta el proyecto?

Si este proyecto te ha sido útil, considera:

- ⭐ **Darle una estrella** al repositorio
- 🍴 **Hacer fork** para tus propios proyectos
- 📢 **Compartirlo** con otros desarrolladores
- 🐛 **Reportar issues** para mejorarlo
- 💡 **Sugerir nuevas características**

---

<div align="center">

**🚀 ¡Servidor Ubuntu listo para producción en minutos!**

*Configuración profesional • Seguridad avanzada • Automatización completa*

[![Built with Love](https://img.shields.io/badge/Built%20with-❤️-red.svg)](https://github.com/hackhit/conf-serv-dev)
[![Made in Venezuela](https://img.shields.io/badge/Made%20in-🇻🇪%20Venezuela-yellow.svg)](https://www.hackhit.info?utm_source=github&utm_medium=referral&utm_campaign=repositorio&utm_content=Hackhit)

</div>
