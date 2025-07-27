# 📡 Documentación de APIs y Servicios

## 🎯 Endpoints de Gestión del Servidor

### 📊 API de Estado del Servidor

Crea un endpoint simple para verificar el estado del servidor.

#### 1. Crear API de Estado

```php
<?php
// /var/www/tu-dominio.com/api/status.php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

$status = [
    'server' => [
        'status' => 'online',
        'timestamp' => date('c'),
        'uptime' => shell_exec('uptime -p'),
        'load' => sys_getloadavg(),
    ],
    'services' => [
        'apache' => service_status('apache2'),
        'bind' => service_status('bind9'),
        'fail2ban' => service_status('fail2ban')
    ],
    'disk' => [
        'usage' => disk_usage('/'),
        'free_space' => disk_free_space('/')
    ],
    'memory' => memory_info()
];

function service_status($service) {
    $output = shell_exec("systemctl is-active $service");
    return trim($output) === 'active';
}

function disk_usage($path) {
    $total = disk_total_space($path);
    $free = disk_free_space($path);
    return round((($total - $free) / $total) * 100, 2);
}

function memory_info() {
    $meminfo = file_get_contents('/proc/meminfo');
    preg_match_all('/(\w+):\s+(\d+)/', $meminfo, $matches);
    $info = array_combine($matches[1], $matches[2]);
    
    return [
        'total' => round($info['MemTotal'] / 1024, 2), // MB
        'available' => round($info['MemAvailable'] / 1024, 2), // MB
        'usage_percent' => round((($info['MemTotal'] - $info['MemAvailable']) / $info['MemTotal']) * 100, 2)
    ];
}

echo json_encode($status, JSON_PRETTY_PRINT);
?>
```

#### 2. Configurar Endpoint en Apache

```apache
# En tu Virtual Host:
<Directory /var/www/tu-dominio.com/api>
    Options -Indexes
    AllowOverride None
    Require all granted
    
    # URL Rewriting para API REST
    RewriteEngine On
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteRule ^(.*)$ index.php [QSA,L]
    
    # Headers CORS
    Header always set Access-Control-Allow-Origin "*"
    Header always set Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"
    Header always set Access-Control-Allow-Headers "Content-Type, Authorization"
</Directory>
```

---

## 🔐 API de Autenticación

### 🎫 Sistema de Tokens JWT

```php
<?php
// /var/www/tu-dominio.com/api/auth.php
require_once 'vendor/autoload.php';
use Firebase\JWT\JWT;
use Firebase\JWT\Key;

class AuthAPI {
    private $secret_key = "tu_clave_secreta_super_segura";
    private $issuer = "tu-dominio.com";
    private $audience = "tu-dominio.com";
    
    public function login($username, $password) {
        // Verificar credenciales (ejemplo básico)
        if ($this->validateCredentials($username, $password)) {
            $payload = [
                'iss' => $this->issuer,
                'aud' => $this->audience,
                'iat' => time(),
                'exp' => time() + 3600, // 1 hora
                'user' => $username,
                'roles' => $this->getUserRoles($username)
            ];
            
            $jwt = JWT::encode($payload, $this->secret_key, 'HS256');
            
            return [
                'success' => true,
                'token' => $jwt,
                'expires_in' => 3600
            ];
        }
        
        return [
            'success' => false,
            'message' => 'Invalid credentials'
        ];
    }
    
    public function validateToken($token) {
        try {
            $decoded = JWT::decode($token, new Key($this->secret_key, 'HS256'));
            return $decoded;
        } catch (Exception $e) {
            return false;
        }
    }
    
    private function validateCredentials($username, $password) {
        // Implementar validación real aquí
        // Por ejemplo, verificar contra base de datos
        return true; // Placeholder
    }
    
    private function getUserRoles($username) {
        // Retornar roles del usuario
        return ['user']; // Placeholder
    }
}

// Manejo de requests
header('Content-Type: application/json');
$auth = new AuthAPI();

switch ($_SERVER['REQUEST_METHOD']) {
    case 'POST':
        $input = json_decode(file_get_contents('php://input'), true);
        if (isset($input['username']) && isset($input['password'])) {
            echo json_encode($auth->login($input['username'], $input['password']));
        } else {
            echo json_encode(['success' => false, 'message' => 'Missing credentials']);
        }
        break;
        
    case 'GET':
        $headers = getallheaders();
        if (isset($headers['Authorization'])) {
            $token = str_replace('Bearer ', '', $headers['Authorization']);
            $decoded = $auth->validateToken($token);
            if ($decoded) {
                echo json_encode(['valid' => true, 'user' => $decoded->user]);
            } else {
                echo json_encode(['valid' => false]);
            }
        } else {
            echo json_encode(['valid' => false, 'message' => 'No token provided']);
        }
        break;
        
    default:
        echo json_encode(['success' => false, 'message' => 'Method not allowed']);
}
?>
```

---

## 📊 API de Monitoreo

### 📈 Métricas del Sistema

```php
<?php
// /var/www/tu-dominio.com/api/metrics.php
header('Content-Type: application/json');

class SystemMetrics {
    
    public function getAllMetrics() {
        return [
            'system' => $this->getSystemInfo(),
            'apache' => $this->getApacheMetrics(),
            'dns' => $this->getDNSMetrics(),
            'security' => $this->getSecurityMetrics(),
            'performance' => $this->getPerformanceMetrics()
        ];
    }
    
    private function getSystemInfo() {
        return [
            'hostname' => gethostname(),
            'os' => php_uname(),
            'php_version' => phpversion(),
            'server_time' => date('c'),
            'timezone' => date_default_timezone_get(),
            'uptime' => trim(shell_exec('uptime -p')),
            'load_average' => sys_getloadavg()
        ];
    }
    
    private function getApacheMetrics() {
        $status = shell_exec('systemctl status apache2');
        $processes = shell_exec('pgrep -c apache2');
        
        return [
            'status' => strpos($status, 'active (running)') !== false ? 'running' : 'stopped',
            'processes' => (int)$processes,
            'modules' => $this->getEnabledModules(),
            'sites' => $this->getEnabledSites()
        ];
    }
    
    private function getDNSMetrics() {
        $status = shell_exec('systemctl status bind9');
        $queries = $this->getDNSQueries();
        
        return [
            'status' => strpos($status, 'active (running)') !== false ? 'running' : 'stopped',
            'recent_queries' => $queries,
            'zones' => $this->getDNSZones()
        ];
    }
    
    private function getSecurityMetrics() {
        $fail2ban_status = shell_exec('fail2ban-client status');
        
        return [
            'fail2ban_status' => strpos($fail2ban_status, 'Server ready') !== false ? 'active' : 'inactive',
            'banned_ips' => $this->getBannedIPs(),
            'ssl_certificates' => $this->getSSLStatus()
        ];
    }
    
    private function getPerformanceMetrics() {
        return [
            'memory' => $this->getMemoryUsage(),
            'disk' => $this->getDiskUsage(),
            'network' => $this->getNetworkStats(),
            'cpu' => $this->getCPUUsage()
        ];
    }
    
    private function getEnabledModules() {
        $modules = shell_exec('apache2ctl -M');
        return explode("\n", trim($modules));
    }
    
    private function getEnabledSites() {
        $sites = shell_exec('apache2ctl -S');
        return explode("\n", trim($sites));
    }
    
    private function getDNSQueries() {
        // Parsear logs de BIND para obtener consultas recientes
        $logs = shell_exec('tail -100 /var/log/syslog | grep named');
        return explode("\n", trim($logs));
    }
    
    private function getDNSZones() {
        $zones = shell_exec('rndc status | grep zones');
        return trim($zones);
    }
    
    private function getBannedIPs() {
        $banned = shell_exec('fail2ban-client status apache-auth | grep "Banned IP list"');
        return trim($banned);
    }
    
    private function getSSLStatus() {
        $certs = shell_exec('certbot certificates');
        return explode("\n", trim($certs));
    }
    
    private function getMemoryUsage() {
        $meminfo = file_get_contents('/proc/meminfo');
        preg_match_all('/(\w+):\s+(\d+)/', $meminfo, $matches);
        $info = array_combine($matches[1], $matches[2]);
        
        return [
            'total_mb' => round($info['MemTotal'] / 1024, 2),
            'available_mb' => round($info['MemAvailable'] / 1024, 2),
            'usage_percent' => round((($info['MemTotal'] - $info['MemAvailable']) / $info['MemTotal']) * 100, 2)
        ];
    }
    
    private function getDiskUsage() {
        $total = disk_total_space('/');
        $free = disk_free_space('/');
        
        return [
            'total_gb' => round($total / 1024 / 1024 / 1024, 2),
            'free_gb' => round($free / 1024 / 1024 / 1024, 2),
            'usage_percent' => round((($total - $free) / $total) * 100, 2)
        ];
    }
    
    private function getNetworkStats() {
        $stats = file_get_contents('/proc/net/dev');
        return explode("\n", trim($stats));
    }
    
    private function getCPUUsage() {
        $load = sys_getloadavg();
        return [
            '1min' => $load[0],
            '5min' => $load[1],
            '15min' => $load[2]
        ];
    }
}

$metrics = new SystemMetrics();
echo json_encode($metrics->getAllMetrics(), JSON_PRETTY_PRINT);
?>
```

---

## 🔧 API de Configuración

### ⚙️ Gestión de Configuraciones

```php
<?php
// /var/www/tu-dominio.com/api/config.php
header('Content-Type: application/json');

class ConfigAPI {
    private $config_files = [
        'apache' => '/etc/apache2/sites-available/',
        'dns' => '/etc/bind/',
        'fail2ban' => '/etc/fail2ban/jail.local'
    ];
    
    public function getConfig($service, $file = null) {
        switch ($service) {
            case 'apache':
                return $this->getApacheConfig($file);
            case 'dns':
                return $this->getDNSConfig($file);
            case 'fail2ban':
                return $this->getFail2banConfig();
            default:
                return ['error' => 'Service not found'];
        }
    }
    
    public function updateConfig($service, $file, $content) {
        // Implementar validación y backup antes de actualizar
        if ($this->validateConfig($service, $content)) {
            return $this->writeConfig($service, $file, $content);
        }
        return ['error' => 'Invalid configuration'];
    }
    
    private function getApacheConfig($file) {
        if ($file) {
            $path = $this->config_files['apache'] . $file;
            if (file_exists($path)) {
                return ['content' => file_get_contents($path)];
            }
        }
        
        // Listar todos los archivos de configuración
        $files = scandir($this->config_files['apache']);
        return ['files' => array_filter($files, function($f) {
            return substr($f, -5) === '.conf';
        })];
    }
    
    private function getDNSConfig($file) {
        if ($file) {
            $path = $this->config_files['dns'] . $file;
            if (file_exists($path)) {
                return ['content' => file_get_contents($path)];
            }
        }
        
        $files = ['named.conf.local'];
        $zone_files = glob($this->config_files['dns'] . 'db.*');
        return ['files' => array_merge($files, $zone_files)];
    }
    
    private function getFail2banConfig() {
        $path = $this->config_files['fail2ban'];
        if (file_exists($path)) {
            return ['content' => file_get_contents($path)];
        }
        return ['error' => 'Config file not found'];
    }
    
    private function validateConfig($service, $content) {
        // Implementar validación específica para cada servicio
        switch ($service) {
            case 'apache':
                return $this->validateApacheConfig($content);
            case 'dns':
                return $this->validateDNSConfig($content);
            case 'fail2ban':
                return $this->validateFail2banConfig($content);
        }
        return false;
    }
    
    private function validateApacheConfig($content) {
        // Escribir archivo temporal y usar apache2ctl configtest
        $temp_file = tempnam(sys_get_temp_dir(), 'apache_test_');
        file_put_contents($temp_file, $content);
        
        $result = shell_exec("apache2ctl -t -f $temp_file 2>&1");
        unlink($temp_file);
        
        return strpos($result, 'Syntax OK') !== false;
    }
    
    private function validateDNSConfig($content) {
        // Escribir archivo temporal y usar named-checkzone
        $temp_file = tempnam(sys_get_temp_dir(), 'dns_test_');
        file_put_contents($temp_file, $content);
        
        $result = shell_exec("named-checkzone test.com $temp_file 2>&1");
        unlink($temp_file);
        
        return strpos($result, 'OK') !== false;
    }
    
    private function validateFail2banConfig($content) {
        // Validación básica de sintaxis
        return true; // Implementar validación real
    }
    
    private function writeConfig($service, $file, $content) {
        // Crear backup antes de escribir
        $path = $this->getConfigPath($service, $file);
        
        if (file_exists($path)) {
            copy($path, $path . '.backup.' . date('YmdHis'));
        }
        
        if (file_put_contents($path, $content) !== false) {
            // Recargar servicio
            $this->reloadService($service);
            return ['success' => true, 'message' => 'Configuration updated'];
        }
        
        return ['error' => 'Failed to write configuration'];
    }
    
    private function getConfigPath($service, $file) {
        return $this->config_files[$service] . $file;
    }
    
    private function reloadService($service) {
        switch ($service) {
            case 'apache':
                shell_exec('systemctl reload apache2');
                break;
            case 'dns':
                shell_exec('systemctl reload bind9');
                break;
            case 'fail2ban':
                shell_exec('systemctl restart fail2ban');
                break;
        }
    }
}

// Manejo de requests
$config_api = new ConfigAPI();
$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'GET':
        $service = $_GET['service'] ?? null;
        $file = $_GET['file'] ?? null;
        echo json_encode($config_api->getConfig($service, $file));
        break;
        
    case 'POST':
        $input = json_decode(file_get_contents('php://input'), true);
        $service = $input['service'] ?? null;
        $file = $input['file'] ?? null;
        $content = $input['content'] ?? null;
        
        if ($service && $file && $content) {
            echo json_encode($config_api->updateConfig($service, $file, $content));
        } else {
            echo json_encode(['error' => 'Missing parameters']);
        }
        break;
        
    default:
        echo json_encode(['error' => 'Method not allowed']);
}
?>
```

---

## 📱 Cliente JavaScript para APIs

### 🌐 SDK de Cliente

```javascript
// /var/www/tu-dominio.com/js/server-api.js
class ServerAPI {
    constructor(baseURL, token = null) {
        this.baseURL = baseURL;
        this.token = token;
    }
    
    async request(endpoint, options = {}) {
        const url = `${this.baseURL}${endpoint}`;
        const config = {
            headers: {
                'Content-Type': 'application/json',
                ...(this.token && { 'Authorization': `Bearer ${this.token}` }),
                ...options.headers
            },
            ...options
        };
        
        try {
            const response = await fetch(url, config);
            const data = await response.json();
            
            if (!response.ok) {
                throw new Error(data.message || 'Request failed');
            }
            
            return data;
        } catch (error) {
            console.error('API Error:', error);
            throw error;
        }
    }
    
    // Autenticación
    async login(username, password) {
        const data = await this.request('/api/auth.php', {
            method: 'POST',
            body: JSON.stringify({ username, password })
        });
        
        if (data.success) {
            this.token = data.token;
            localStorage.setItem('server_token', data.token);
        }
        
        return data;
    }
    
    async validateToken() {
        return await this.request('/api/auth.php');
    }
    
    // Estado del servidor
    async getServerStatus() {
        return await this.request('/api/status.php');
    }
    
    // Métricas
    async getMetrics() {
        return await this.request('/api/metrics.php');
    }
    
    // Configuración
    async getConfig(service, file = null) {
        const params = new URLSearchParams({ service });
        if (file) params.append('file', file);
        
        return await this.request(`/api/config.php?${params}`);
    }
    
    async updateConfig(service, file, content) {
        return await this.request('/api/config.php', {
            method: 'POST',
            body: JSON.stringify({ service, file, content })
        });
    }
}

// Dashboard en tiempo real
class ServerDashboard {
    constructor(api) {
        this.api = api;
        this.updateInterval = null;
    }
    
    async init() {
        await this.loadInitialData();
        this.startAutoUpdate();
        this.setupEventListeners();
    }
    
    async loadInitialData() {
        try {
            const [status, metrics] = await Promise.all([
                this.api.getServerStatus(),
                this.api.getMetrics()
            ]);
            
            this.updateStatusDisplay(status);
            this.updateMetricsDisplay(metrics);
        } catch (error) {
            this.showError('Failed to load server data');
        }
    }
    
    startAutoUpdate() {
        this.updateInterval = setInterval(async () => {
            try {
                const status = await this.api.getServerStatus();
                this.updateStatusDisplay(status);
            } catch (error) {
                console.error('Auto-update failed:', error);
            }
        }, 30000); // Actualizar cada 30 segundos
    }
    
    updateStatusDisplay(status) {
        // Actualizar elementos del DOM con datos de estado
        document.getElementById('server-status').textContent = status.server.status;
        document.getElementById('uptime').textContent = status.server.uptime;
        document.getElementById('memory-usage').textContent = `${status.memory.usage_percent}%`;
        document.getElementById('disk-usage').textContent = `${status.disk.usage}%`;
        
        // Actualizar estado de servicios
        Object.entries(status.services).forEach(([service, isActive]) => {
            const element = document.getElementById(`service-${service}`);
            if (element) {
                element.className = isActive ? 'service-active' : 'service-inactive';
                element.textContent = isActive ? 'Active' : 'Inactive';
            }
        });
    }
    
    updateMetricsDisplay(metrics) {
        // Crear gráficos o actualizar métricas
        this.createCPUChart(metrics.performance.cpu);
        this.createMemoryChart(metrics.performance.memory);
    }
    
    createCPUChart(cpuData) {
        // Implementar gráfico de CPU usando Chart.js o similar
    }
    
    createMemoryChart(memoryData) {
        // Implementar gráfico de memoria
    }
    
    setupEventListeners() {
        // Configurar event listeners para controles del dashboard
        document.getElementById('refresh-btn').addEventListener('click', () => {
            this.loadInitialData();
        });
        
        document.getElementById('stop-auto-update').addEventListener('click', () => {
            if (this.updateInterval) {
                clearInterval(this.updateInterval);
                this.updateInterval = null;
            }
        });
    }
    
    showError(message) {
        const errorDiv = document.getElementById('error-messages');
        errorDiv.innerHTML = `<div class="alert alert-danger">${message}</div>`;
        setTimeout(() => {
            errorDiv.innerHTML = '';
        }, 5000);
    }
    
    destroy() {
        if (this.updateInterval) {
            clearInterval(this.updateInterval);
        }
    }
}

// Uso
document.addEventListener('DOMContentLoaded', async () => {
    const api = new ServerAPI('https://tu-dominio.com');
    
    // Cargar token guardado
    const savedToken = localStorage.getItem('server_token');
    if (savedToken) {
        api.token = savedToken;
    }
    
    const dashboard = new ServerDashboard(api);
    await dashboard.init();
});
```

---

## 📖 Documentación de Endpoints

### 📍 Lista Completa de Endpoints

| Endpoint | Método | Descripción | Autenticación |
|----------|--------|-------------|---------------|
| `/api/status.php` | GET | Estado general del servidor | No |
| `/api/metrics.php` | GET | Métricas detalladas del sistema | Sí |
| `/api/auth.php` | POST | Login y obtención de token | No |
| `/api/auth.php` | GET | Validación de token | Sí |
| `/api/config.php` | GET | Obtener configuraciones | Sí |
| `/api/config.php` | POST | Actualizar configuraciones | Sí |

### 📝 Ejemplos de Uso

```bash
# Obtener estado del servidor
curl https://tu-dominio.com/api/status.php

# Login
curl -X POST https://tu-dominio.com/api/auth.php \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"password"}'

# Obtener métricas (con token)
curl https://tu-dominio.com/api/metrics.php \
  -H "Authorization: Bearer YOUR_TOKEN"

# Obtener configuración de Apache
curl "https://tu-dominio.com/api/config.php?service=apache&file=tu-dominio.conf" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

**🔒 Nota de Seguridad**: Todas las APIs que manejan configuraciones requieren autenticación. Implementa rate limiting y validación adicional en producción.