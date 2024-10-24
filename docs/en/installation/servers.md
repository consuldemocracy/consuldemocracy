# Production and staging servers

## Recommended minimum system requirements

### 1. Production server

- Supported distributions: Ubuntu 22.04, Ubuntu 24.04, Debian Bullseye or Debian Bookworm
- RAM: 32GB
- Processor: Quad core
- Hard Drive: 20 GB
- Database: Postgres

### 2. Staging server

- Supported distributions: Ubuntu 22.04, Ubuntu 24.04, Debian Bullseye or Debian Bookworm
- RAM: 16GB
- Processor: Dual core
- Hard Drive: 20 GB
- Database: Postgres

If your city has a population of over 1,000,000, consider balancing your load using 2-3 production servers and a separate server for the database.
