---
name: Bug Report
about: Reportar un problema o error
title: '[BUG] '
labels: bug
assignees: hackhit
---

## 🐛 Descripción del Bug

Descripción clara y concisa del problema.

## 🔄 Pasos para Reproducir

1. Ir a '...'
2. Ejecutar '...'
3. Ver error

## ✅ Comportamiento Esperado

Descripción clara de qué esperabas que sucediera.

## ❌ Comportamiento Actual

Descripción clara de qué está sucediendo actualmente.

## 🖼️ Screenshots

Si aplica, agregar screenshots para ayudar a explicar el problema.

## 🖥️ Información del Sistema

- **OS**: [ej. Ubuntu 20.04]
- **Versión del proyecto**: [ej. 1.0.0]
- **Apache**: [ej. 2.4.41]
- **BIND9**: [ej. 9.16.1]
- **PHP**: [ej. 8.1] (si aplica)

## 📋 Logs Relevantes

```bash
# Pegar logs relevantes aquí
# Apache error log:
sudo tail -50 /var/log/apache2/error.log

# DNS logs:
sudo tail -50 /var/log/syslog | grep named

# System logs:
sudo journalctl -xe
```

## 🔧 Configuración

```bash
# Resultado del script de verificación
sudo ./scripts/server_check.sh
```

## 📝 Contexto Adicional

Cualquier otra información relevante sobre el problema.

## ✅ Checklist

- [ ] He buscado en issues existentes
- [ ] He ejecutado `./scripts/server_check.sh`
- [ ] He incluido logs relevantes
- [ ] He probado en un entorno limpio
- [ ] He seguido la documentación de troubleshooting