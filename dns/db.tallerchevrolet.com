;
; Archivo de zona para tallerchevrolet.com
; Archivo: /etc/bind/db.tallerchevrolet.com
; IP Externa: 38.10.252.121
; IP Interna: 192.168.1.167
;
$TTL    604800
@       IN      SOA     tallerchevrolet.com. admin.tallerchevrolet.com. (
                         2025072601     ; Serial (YYYYMMDDNN) - Incrementar al hacer cambios
                         604800         ; Refresh (1 semana)
                         86400          ; Retry (1 día)
                         2419200        ; Expire (4 semanas)
                         604800 )       ; Negative Cache TTL (1 semana)

; Servidores de nombres
@       IN      NS      ns1.tallerchevrolet.com.
@       IN      NS      ns2.tallerchevrolet.com.

; Registros A - IP Pública del servidor
@       IN      A       38.10.252.121
www     IN      A       38.10.252.121
ns1     IN      A       38.10.252.121
ns2     IN      A       38.10.252.121

; Servicios del taller
mail    IN      A       38.10.252.121
ftp     IN      A       38.10.252.121
admin   IN      A       38.10.252.121
api     IN      A       38.10.252.121
citas   IN      A       38.10.252.121
diagnostico IN  A       38.10.252.121
servicios IN   A       38.10.252.121

; Subdominios para diferentes servicios
portal  IN      A       38.10.252.121
intranet IN     A       38.10.252.121
sistemas IN     A       38.10.252.121

; Comodín para subdominios no especificados
*       IN      A       38.10.252.121

; Registro MX para correo electrónico
@       IN      MX      10      mail.tallerchevrolet.com.

; Registros TXT para verificación y SPF
@       IN      TXT     "v=spf1 a mx ip4:38.10.252.121 ~all"
@       IN      TXT     "Taller Chevrolet - Servicio Tecnico Especializado"

; Registro AAAA para IPv6 (opcional, comentado)
; @     IN      AAAA    ::1
