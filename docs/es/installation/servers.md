# Servidores de producción y pruebas

## Requisitos de sistema mínimos recomendados

### 1. Servidor de producción

- Distribuciones compatibles: Ubuntu 22.04, Ubuntu 24.04, Debian Bullseye o Debian Bookworm
- RAM: 32GB
- Procesador: Quad core
- Disco duro: 20 GB
- Base de datos: Postgres

### 2. Servidor de pruebas

- Distribuciones compatibles: Ubuntu 22.04, Ubuntu 24.04, Debian Bullseye o Debian Bookworm
- RAM: 16GB
- Procesador: Dual core
- Disco duro: 20 GB
- Base de datos: Postgres

Si tu ciudad tiene una población superior a 1.000.000, considera añadir un balanceador de carga y usar 2-3 servidores de producción, además de un servidor de base de datos dedicado.
