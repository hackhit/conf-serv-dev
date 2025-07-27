#!/bin/bash

# ===============================================
# SCRIPT DE VERIFICACION Y MANTENIMIENTO DEL SERVIDOR
# Proyecto: conf-serv-dev
# Dev: Miguel Hernandez - Hackhit
# ===============================================

echo "VERIFICACION COMPLETA DEL SERVIDOR"
echo "====================================="

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funcion para mostrar estado de servicios
check_service() {
    local service_name=$1
    if systemctl is-active --quiet $service_name; then
        echo -e "${GREEN} OK $service_name: FUNCIONANDO${NC}"
        return 0
    else
        echo -e "${RED} ERROR $service_name: DETENIDO${NC}"
        return 1
    fi
}

# Funcion para verificar puertos
check_port() {
    local port=$1
    local service=$2
    if netstat -tuln | grep -q ":$port "; then
        echo -e "${GREEN} OK Puerto $port ($service): ABIERTO${NC}"
        return 0
    else
        echo -e "${RED} ERROR Puerto $port ($service): CERRADO${NC}"
        return 1
    fi
}

# Funcion para verificar sitios web
check_website() {
    local url=$1
    local response=$(curl -s -o /dev/null -w "%{http_code}" $url)
    
    if [ "$response" = "200" ]; then
        echo -e "${GREEN} OK $url: ACCESIBLE (HTTP $response)${NC}"
        return 0
    else
        echo -e "${RED} ERROR $url: ERROR (HTTP $response)${NC}"
        return 1
    fi
}

echo ""
echo " ESTADO DE SERVICIOS PRINCIPALES"
echo "=================================="
check_service "apache2"
check_service "bind9"
check_service "fail2ban"
check_service "ssh"

echo ""
echo " VERIFICACION DE PUERTOS"
echo "=========================="
check_port "80" "HTTP"
check_port "443" "HTTPS"
check_port "53" "DNS"
check_port "22" "SSH"

echo ""
echo " VERIFICACION DE SITIOS WEB"
echo "============================="
check_website "http://tallerchevrolet.com"
check_website "http://repuestoschevy.com"
check_website "http://deosvenezuela.com"

echo ""
echo " INFORMACION DEL SISTEMA"
echo "=========================="
echo -e "${BLUE}Fecha y hora:${NC} $(date)"
echo -e "${BLUE}Uptime:${NC} $(uptime -p)"
echo -e "${BLUE}Uso de memoria:${NC}"
free -h | grep -E "(Mem|Swap)"
echo -e "${BLUE}Uso de disco:${NC}"
df -h | grep -E "(/$|/var|/home)"

echo ""
echo " ESTADO DE FAIL2BAN"
echo "====================="
if command -v fail2ban-client &> /dev/null; then
    fail2ban-client status
else
    echo "Fail2ban no esta instalado"
fi

echo ""
echo " CERTIFICADOS SSL"
echo "=================="
if command -v certbot &> /dev/null; then
    certbot certificates 2>/dev/null || echo "No hay certificados configurados"
else
    echo "Certbot no esta instalado"
fi

echo ""
echo " VERIFICACION COMPLETADA"
echo "=========================="
echo "Fecha del reporte: $(date)"
echo "Servidor: $(hostname) - IP: 192.168.1.167 (Externa: 38.10.252.121)"
