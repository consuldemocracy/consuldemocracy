# Docker Deployment Guide for Consul Democracy

This guide explains how to deploy Consul Democracy using Docker and Kamal.

## Prerequisites

- Docker installed on your server
- A container registry (e.g., Docker Hub, DigitalOcean Container Registry)
- SSH access to your deployment server
- Domain name pointing to your server

## Configuration

1. Update `config/deploy.yml` with your specific settings:
   - Replace `192.168.0.1` with your actual server IP
   - Update `consul.example.com` with your domain
   - Configure your container registry details

2. Set up environment variables:
   ```bash
   kamal env set RAILS_MASTER_KEY=your_master_key
   kamal env set SECRET_KEY_BASE=your_secret_key
   kamal env set DATABASE_URL=postgresql://user:password@host:5432/consul_production
   kamal env set REDIS_URL=redis://host:6379/1
   ```

## Deployment

1. Build and push the Docker image:
   ```bash
   kamal build
   ```

2. Deploy the application:
   ```bash
   kamal deploy
   ```

3. Monitor the deployment:
   ```bash
   kamal app logs
   ```

## Health Checks

The application includes a health check endpoint at `/health` that returns a 200 status code when the application is running properly.

## Database and Redis

The configuration includes PostgreSQL and Redis as accessories. Make sure to:
1. Set up the database and Redis servers
2. Configure the connection details in `config/deploy.yml`
3. Set the necessary environment variables

## Troubleshooting

If you encounter issues:
1. Check the logs: `kamal app logs`
2. Verify environment variables: `kamal env`
3. Check container status: `kamal app status`

## Maintenance

- To update the application: `kamal deploy`
- To rollback: `kamal rollback`
- To remove the deployment: `kamal remove` 