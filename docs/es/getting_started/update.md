# Manten tu fork actualizado

## Configura tus servidores remotos de git

Si creaste correctamente tu fork y lo clonaste localmente, usando:

```bash
git remote -v
```

deberías ver algo como:

> origin  git@github.com:your_user_name/consul.git (fetch)\
> origin  git@github.com:your_user_name/consul.git (push)

Ahora debes añadir el repositorio git de CONSUL como servidor remoto con:

```bash
git remote add upstream git@github.com:consul/consul.git
```

comprueba de nuevo que con:

```bash
git remote -v
```

deberías recibir algo como:

> upstream  git@github.com:consul/consul.git (fetch)\
> upstream  git@github.com:consul/consul.git (push)\
> origin  git@github.com:your_user_name/consul.git (fetch)\
> origin  git@github.com:your_user_name/consul.git (push)

## Obteniendo cambios de consul

Empieza creando una rama **upstream** a partir de tu rama **master** sobre la que trabajar:

```bash
git checkout master
git pull
git checkout -b upstream
```

Y actualiza la información del repositorio de consul con las referencias a las ramas, tags, etc..:

```bash
git fetch upstream
```

Y por fin puedes elegir entre:

A. Actualizar con los últimos cambios de la rama **master** usando `git merge upstream/master`

B. Sólo actualizar hasta cierta versión (en el caso de que prefieras actualizar de forma incremental, si estas varias versiones por detrás). Por ejemplo para actualizarte a la versión [v0.9](https://github.com/consul/consul/releases/tag/v0.9) utilizamos el tag asociado: `git merge v0.9`

## Fusionando cambios

Tras el `merge` de la anterior sección, hay tres posibles escenarios:

A. Obtienes una respuesta `Already up-to-date.`. Eso significa que tu fork esta al dia con los cambios de CONSUL 😊👌

B. Se abre una ventana del editor que tengas configurado en git, mostrando el mensaje de commit `Merge remote-tracking branch 'upstream/master' into upstream`. Esto significa que git fue capaz de mezclar los cambios de CONSUL sobre tu código sin encontrar problemas o conflictos. Termina el commit.

C. Recibes mensajes de error de git junto con un `Automatic merge failed; fix conflicts and then commit the result.`. Esto significa que se han encontrado conflictos entre los cambios en tu código y los cambios que se realizaron en CONSUL desde la última vez que actualizaste tu fork. Esta es una de las principales razones para intentar mantener tu fork lo más al dia posible, realizando este proceso al menos mensualmente. Resuelve manualmente los conflictos para terminar el merge y haz un commit.

Ahora simplemente sube la rama **upstream** a github y crea un Pull Request, así podrás ver de manera sencilla todos los cambios que se han realizado en el repositorio y verás también como arranca la suite de tests.

Recuerda que siempre puedes comprobar rápidamente los cambios que tienes pendientes de integrar de CONSUL a tu fork sustituyendo **your_org_name** en la url: <https://github.com/your_org_name/consul/compare/master...consul:master>
