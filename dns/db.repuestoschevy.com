;
; Archivo de zona para repuestoschevy.com
; Archivo: /etc/bind/db.repuestoschevy.com
; IP Externa: 38.10.252.121
; IP Interna: 192.168.1.167
;
$TTL    604800
@       IN      SOA     repuestoschevy.com. admin.repuestoschevy.com. (
                         2025072601     ; Serial (YYYYMMDDNN) - Incrementar al hacer cambios
                         604800         ; Refresh (1 semana)
                         86400          ; Retry (1 día)
                         2419200        ; Expire (4 semanas)
                         604800 )       ; Negative Cache TTL (1 semana)

; Servidores de nombres
@       IN      NS      ns1.repuestoschevy.com.
@       IN      NS      ns2.repuestoschevy.com.

; Registros A - IP Pública del servidor
@       IN      A       38.10.252.121
www     IN      A       38.10.252.121
ns1     IN      A       38.10.252.121
ns2     IN      A       38.10.252.121

; Servicios de la tienda de repuestos
mail    IN      A       38.10.252.121
ftp     IN      A       38.10.252.121
admin   IN      A       38.10.252.121
api     IN      A       38.10.252.121
tienda  IN      A       38.10.252.121
catalogo IN     A       38.10.252.121
inventario IN   A       38.10.252.121
pagos   IN      A       38.10.252.121

; E-commerce y gestión
carrito IN      A       38.10.252.121
checkout IN     A       38.10.252.121
clientes IN     A       38.10.252.121
pedidos IN      A       38.10.252.121
facturacion IN  A       38.10.252.121

; Subdominios administrativos
intranet IN     A       38.10.252.121
sistemas IN     A       38.10.252.121
reportes IN     A       38.10.252.121

; Comodín para subdominios no especificados
*       IN      A       38.10.252.121

; Registro MX para correo electrónico
@       IN      MX      10      mail.repuestoschevy.com.

; Registros TXT para verificación y SPF
@       IN      TXT     "v=spf1 a mx ip4:38.10.252.121 ~all"
@       IN      TXT     "Repuestos Chevy - Repuestos Originales y Compatibles"

; Registro AAAA para IPv6 (opcional, comentado)
; @     IN      AAAA    ::1
