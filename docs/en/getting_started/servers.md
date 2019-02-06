# Production and Staging servers

## Recommended Minimum System Requirements:

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

If your city has a population of over 1.000.000, consider balancing your load using 2-3 production servers and a separate server for the database.

## Installation notes
Check out the [installer's README](https://github.com/consul/installer)
