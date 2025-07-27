;
; Archivo de zona para deosvenezuela.com
; Archivo: /etc/bind/db.deosvenezuela.com
; IP Externa: 38.10.252.121
; IP Interna: 192.168.1.167
;
$TTL    604800
@       IN      SOA     deosvenezuela.com. admin.deosvenezuela.com. (
                         2025072601     ; Serial (YYYYMMDDNN) - Incrementar al hacer cambios
                         604800         ; Refresh (1 semana)
                         86400          ; Retry (1 día)
                         2419200        ; Expire (4 semanas)
                         604800 )       ; Negative Cache TTL (1 semana)

; Servidores de nombres
@       IN      NS      ns1.deosvenezuela.com.
@       IN      NS      ns2.deosvenezuela.com.

; Registros A - IP Pública del servidor
@       IN      A       38.10.252.121
www     IN      A       38.10.252.121
ns1     IN      A       38.10.252.121
ns2     IN      A       38.10.252.121

; Servicios corporativos
mail    IN      A       38.10.252.121
ftp     IN      A       38.10.252.121
admin   IN      A       38.10.252.121
api     IN      A       38.10.252.121
blog    IN      A       38.10.252.121
portal  IN      A       38.10.252.121
noticias IN     A       38.10.252.121

; Áreas corporativas
rrhh    IN      A       38.10.252.121
finanzas IN     A       38.10.252.121
ventas  IN      A       38.10.252.121
marketing IN    A       38.10.252.121
soporte IN      A       38.10.252.121
legal   IN      A       38.10.252.121

; Sistemas internos
intranet IN     A       38.10.252.121
sistemas IN     A       38.10.252.121
reportes IN     A       38.10.252.121
documentos IN   A       38.10.252.121
capacitacion IN A       38.10.252.121

; Subdominios regionales
caracas IN      A       38.10.252.121
maracaibo IN    A       38.10.252.121
valencia IN     A       38.10.252.121

; Comodín para subdominios no especificados
*       IN      A       38.10.252.121

; Registro MX para correo electrónico
@       IN      MX      10      mail.deosvenezuela.com.

; Registros TXT para verificación y SPF
@       IN      TXT     "v=spf1 a mx ip4:38.10.252.121 ~all"
@       IN      TXT     "Deos Venezuela - Portal Corporativo"

; Registro AAAA para IPv6 (opcional, comentado)
; @     IN      AAAA    ::1
