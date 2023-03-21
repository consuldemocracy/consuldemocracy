# Servidores de producción y pruebas

## Requisitos de sistema mínimos recomendados:

### 1. Production Server:

- Distrubution: Ubuntu 16.04.X
- RAM: 32GB
- Processor: Quad core
- Hard Drive: 20 GB
- Database: Postgres

### 2. Staging Server:

- Distrubution: Ubuntu 16.04.X
- RAM: 16GB
- Processor: Dual core
- Hard Drive: 20 GB
- Database: Postgres

Si tu ciudad tiene una población superior a 1.000.000, considera añadir un balanceador de carga y usar 2-3 servidores de producción, además de un servidor de base de datos dedicado.
