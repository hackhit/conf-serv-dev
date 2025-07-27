;
; Archivo de zona para example-domain.com
; Archivo: /etc/bind/db.example-domain.com
; IP Externa: 38.10.252.121
; IP Interna: 192.168.1.167
;
; INSTRUCCIONES:
; 1. Copiar este archivo y renombrar según tu dominio
; 2. Reemplazar "example-domain.com" con tu dominio real
; 3. Ajustar subdominios según necesidades
; 4. Incrementar serial al hacer cambios
; 5. Agregar zona en /etc/bind/named.conf.local
;
$TTL    604800
@       IN      SOA     example-domain.com. admin.example-domain.com. (
                         2024072601     ; Serial (YYYYMMDDNN) - INCREMENTAR AL HACER CAMBIOS
                         604800         ; Refresh (1 semana)
                         86400          ; Retry (1 día)
                         2419200        ; Expire (4 semanas)
                         604800 )       ; Negative Cache TTL (1 semana)

; ===============================================
; SERVIDORES DE NOMBRES
; ===============================================
@       IN      NS      ns1.example-domain.com.
@       IN      NS      ns2.example-domain.com.

; ===============================================
; REGISTROS A PRINCIPALES - IP PÚBLICA DEL SERVIDOR
; ===============================================
@       IN      A       38.10.252.121
www     IN      A       38.10.252.121
ns1     IN      A       38.10.252.121
ns2     IN      A       38.10.252.121

; ===============================================
; SUBDOMINIOS DE SERVICIOS BÁSICOS
; ===============================================
mail    IN      A       38.10.252.121
ftp     IN      A       38.10.252.121
admin   IN      A       38.10.252.121
api     IN      A       38.10.252.121
blog    IN      A       38.10.252.121
shop    IN      A       38.10.252.121
app     IN      A       38.10.252.121

; ===============================================
; SUBDOMINIOS TÉCNICOS
; ===============================================
dev     IN      A       38.10.252.121
test    IN      A       38.10.252.121
staging IN      A       38.10.252.121
beta    IN      A       38.10.252.121
mobile  IN      A       38.10.252.121

; ===============================================
; SUBDOMINIOS DE SERVICIOS ESPECÍFICOS
; ===============================================
; Personalizar según el tipo de sitio:

; Para E-commerce:
; tienda  IN      A       38.10.252.121
; carrito IN      A       38.10.252.121
; pagos   IN      A       38.10.252.121
; cuenta  IN      A       38.10.252.121

; Para Empresa/Corporativo:
; intranet IN     A       38.10.252.121
; portal  IN      A       38.10.252.121
; rrhh    IN      A       38.10.252.121
; ventas  IN      A       38.10.252.121

; Para Servicios/SaaS:
; dashboard IN    A       38.10.252.121
; console IN      A       38.10.252.121
; docs    IN      A       38.10.252.121
; status  IN      A       38.10.252.121

; ===============================================
; COMODÍN PARA SUBDOMINIOS NO ESPECIFICADOS
; ===============================================
*       IN      A       38.10.252.121

; ===============================================
; REGISTROS MX PARA CORREO ELECTRÓNICO
; ===============================================
@       IN      MX      10      mail.example-domain.com.

; Para usar servicios externos como Gmail:
; @       IN      MX      1       aspmx.l.google.com.
; @       IN      MX      5       alt1.aspmx.l.google.com.
; @       IN      MX      5       alt2.aspmx.l.google.com.
; @       IN      MX      10      alt3.aspmx.l.google.com.
; @       IN      MX      10      alt4.aspmx.l.google.com.

; ===============================================
; REGISTROS TXT PARA VERIFICACIÓN Y SPF
; ===============================================
@       IN      TXT     "v=spf1 a mx ip4:38.10.252.121 ~all"
@       IN      TXT     "example-domain.com - Descripción del sitio"

; Para verificación de Google:
; @       IN      TXT     "google-site-verification=CÓDIGO_DE_GOOGLE"

; Para DKIM (si usas correo):
; default._domainkey IN TXT "v=DKIM1; k=rsa; p=CLAVE_PÚBLICA_DKIM"

; Para DMARC:
; _dmarc  IN      TXT     "v=DMARC1; p=quarantine; rua=mailto:dmarc@example-domain.com"

; ===============================================
; REGISTROS SRV (SERVICIOS)
; ===============================================
; Para servicios específicos como SIP, XMPP, etc.
; _sip._tcp       IN      SRV     10 5 5060 sip.example-domain.com.
; _xmpp-server._tcp IN    SRV     5 0 5269 xmpp.example-domain.com.

; ===============================================
; REGISTROS AAAA PARA IPv6 (OPCIONAL)
; ===============================================
; Descomentar si tienes IPv6:
; @     IN      AAAA    2001:db8::1
; www   IN      AAAA    2001:db8::1

; ===============================================
; REGISTROS CNAME (ALIAS)
; ===============================================
; Usar con cuidado, no mezclar con registros A
; cdn   IN      CNAME   cloudfront.amazonaws.com.
; docs  IN      CNAME   readthedocs.io.

; ===============================================
; NOTAS IMPORTANTES:
; ===============================================
; 
; 1. INCREMENTAR SERIAL: Cada vez que hagas cambios,
;    incrementa el número serial (ej: 2024072601 -> 2024072602)
;
; 2. VERIFICAR SINTAXIS:
;    sudo named-checkzone example-domain.com /etc/bind/db.example-domain.com
;
; 3. RECARGAR DNS:
;    sudo systemctl reload bind9
;
; 4. PROPAGAR CAMBIOS:
;    Los cambios DNS pueden tardar hasta 48 horas en propagarse
;
; 5. TESTING:
;    nslookup example-domain.com localhost
;    dig @localhost example-domain.com
;