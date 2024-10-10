# Configura tu fork

## Integración Continua con GitHub Actions

[GitHub Actions](https://docs.github.com/es/actions) es una herramienta integrada en GitHub que permite automatizar tareas como la ejecución de tests cada vez que haces un cambio en tu código. Dado que Consul Democracy ya incluye configuraciones predefinidas para GitHub Actions, habilitar la integración continua en tu fork es muy sencillo.

### Pasos para habilitar GitHub Actions

1. **Habilita GitHub Actions en tu fork**:
   1. Una vez que hayas creado el fork, ve a la pestaña "**Actions**" en tu repositorio en GitHub.
   1. Verás un mensaje que dice: "Workflows aren’t being run on this forked repository". Esto es normal, ya que GitHub deshabilita por defecto los workflows en los nuevos forks por motivos de seguridad.
   1. Haz clic en el botón "**I understand my workflows, go ahead and enable them**" para habilitar los workflows en tu fork.

2. **Verifica la configuración**:
   1. Realiza un cambio en algún archivo del proyecto (por ejemplo, edita un archivo `.md`) en una rama distinta de master y súbelo a tu fork.
   1. Abre una pull request desde nueva rama hacia master en tu fork.
   1. Ve a la pestaña "**Actions**" y verifica que los tests se están ejecutando correctamente en base a los workflows definidos en la carpeta `.github/workflows/` del proyecto.
