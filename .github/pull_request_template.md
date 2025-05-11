# Docker and Kamal Integration for Consul Democracy

## Description
This PR implements Docker and Kamal integration for Consul Democracy, making it easier to deploy and maintain the application in both development and production environments. The changes include production deployment configuration, development environment setup, and GitHub Codespaces integration.

## Changes

### Production Deployment
- Added Kamal configuration in `config/deploy.yml` for production deployment
- Created health check endpoint at `/health` for monitoring
- Added comprehensive deployment documentation in `docs/docker_deployment.md`
- Configured PostgreSQL and Redis as accessories

### Development Environment
- Added `.devcontainer/devcontainer.json` for GitHub Codespaces integration
  - Configured VS Code extensions for Ruby development
  - Set up automatic environment initialization
  - Added port forwarding and user configuration
- Updated `docker-compose.yml` to support both development and production environments
  - Added volume mounts for development
  - Configured services (PostgreSQL, Redis)
  - Set up proper user permissions

### Testing and CI
- Added system tests in `spec/system/docker_deployment_spec.rb`
  - Tests health check endpoint
  - Verifies environment configuration
- Updated GitHub Actions workflow in `.github/workflows/docker.yml`
  - Added feature branch to trigger list (can be removed after merging)
  - Maintained Docker build and test steps

## Testing
- [x] Added system tests for Docker deployment
- [x] CI workflow runs all tests
- [x] Code style checked with pronto
- [x] Docker image builds and tests successfully

## Documentation
- Added detailed deployment guide in `docs/docker_deployment.md`
- Included setup instructions for both development and production environments
- Added troubleshooting guide and maintenance instructions

## Related Issues
Closes #5952

## Notes
- The changes maintain compatibility with existing setup
- No changes to application logic, only deployment configuration
- All tests are passing
- Code style follows project conventions
- **Note for maintainers**: After merging, please remove `feature/docker-kamal-integration` from the trigger branches in `.github/workflows/docker.yml` to keep the configuration clean 