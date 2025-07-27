#!/bin/bash

# ===============================================
# SCRIPT DE CONFIGURACION SSL CON LET'S ENCRYPT
# Proyecto: conf-serv-dev
# Dev: Miguel Hernandez - Hackhit
# Dominios: tallerchevrolet.com, repuestoschevy.com, deosvenezuela.com
# ===============================================

set -e

echo " CONFIGURANDO SSL CON LET'S ENCRYPT..."
echo "========================================"

# Verificar que se ejecute como root
if [[ $EUID -ne 0 ]]; then
   echo " ERROR Este script debe ejecutarse como root (sudo)"
   exit 1
fi

# Verificar que Certbot este instalado
if ! command -v certbot &> /dev/null; then
    echo " Instalando Certbot..."
    apt update
    apt install -y certbot python3-certbot-apache
fi

# Funcion para verificar DNS
check_dns() {
    local domain=$1
    echo " Verificando DNS para $domain..."
    
    resolved_ip=$(nslookup $domain 8.8.8.8 | grep -A1 "Name:" | grep "Address:" | awk '{print $2}' | head -1)
    
    if [ "$resolved_ip" = "38.10.252.121" ]; then
        echo " OK DNS OK para $domain (resuelve a $resolved_ip)"
        return 0
    else
        echo " ERROR DNS no configurado correctamente para $domain"
        echo "   Resuelve a: $resolved_ip (deberia ser 38.10.252.121)"
        return 1
    fi
}

# Funcion para obtener certificado SSL
get_ssl_cert() {
    local domain=$1
    local www_domain="www.$1"
    
    echo " Obteniendo certificado SSL para $domain..."
    
    # Verificar que el sitio este accesible
    if curl -s -I "http://$domain" | grep -q "200 OK"; then
        echo " OK Sitio web accesible: $domain"
    else
        echo " ERROR Sitio web no accesible: $domain"
        return 1
    fi
    
    # Obtener certificado con Certbot
    certbot --apache \
        -d "$domain" \
        -d "$www_domain" \
        --non-interactive \
        --agree-tos \
        --email admin@$domain \
        --redirect
    
    if [ $? -eq 0 ]; then
        echo " OK Certificado SSL configurado exitosamente para $domain"
        return 0
    else
        echo " ERROR Error al configurar SSL para $domain"
        return 1
    fi
}

# Lista de dominios
domains=("tallerchevrolet.com" "repuestoschevy.com" "deosvenezuela.com")

# Verificar DNS para todos los dominios
echo " VERIFICACION DE DNS"
echo "====================="

dns_ok=true
for domain in "${domains[@]}"; do
    if ! check_dns "$domain"; then
        dns_ok=false
    fi
done

if [ "$dns_ok" = false ]; then
    echo ""
    echo " CONFIGURACION DNS INCOMPLETA"
    echo "================================"
    echo ""
    echo "Configura estos registros DNS y espera 15 minutos:"
    for domain in "${domains[@]}"; do
        echo "$domain        A    38.10.252.121"
        echo "www.$domain    A    38.10.252.121"
    done
    exit 1
fi

# Configurar SSL para cada dominio
echo ""
echo " CONFIGURACION DE CERTIFICADOS SSL"
echo "===================================="

success_count=0
for domain in "${domains[@]}"; do
    if get_ssl_cert "$domain"; then
        ((success_count++))
    fi
    sleep 2
done

# Configurar renovacion automatica
echo ""
echo " Configurando renovacion automatica..."
cron_job="0 12 * * * /usr/bin/certbot renew --quiet && /usr/bin/systemctl reload apache2"

if ! crontab -l 2>/dev/null | grep -q "certbot renew"; then
    (crontab -l 2>/dev/null; echo "$cron_job") | crontab -
    echo " OK Renovacion automatica configurada"
fi

echo ""
echo " CONFIGURACION SSL COMPLETADA"
echo "Certificados configurados: $success_count/${#domains[@]}"
echo " Renovacion automatica: Diaria a las 12:00"
echo " Verificar: certbot certificates"
