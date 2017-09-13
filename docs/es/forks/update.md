# Manten tu fork actualizado

## Configura tus servidores remotos de git

Si creaste correctamente tu fork y lo clonaste localmente, usando:

```bash
git remote -v
```

deberías ver algo como:

> origin  git@github.com:your_user_name/consul.git (fetch)<br/>
> origin  git@github.com:your_user_name/consul.git (push)

Ahora debes añadir el repositorio git de consul como servidor remoto con:

```bash
git add remote consul git@github.com:consul/consul.git
``` 

comprueba de nuevo que con:

```bash
git remote -v
```

deberías recibir algo como:

> consul  git@github.com:consul/consul.git (fetch)<br/>
> consul  git@github.com:consul/consul.git (push)<br/>
> origin  git@github.com:your_user_name/consul.git (fetch)<br/>
> origin  git@github.com:your_user_name/consul.git (push)

## Obteniendo cambios de consul

Empieza creando una rama **consul_pull** a partir de tu rama **master** sobre la que trabajar:

```bash
git checkout master
git checkout -b consul_pull
```

Obten los cambios de la rama **master** del servidor **consul** y unelos a los de la rama de trabajo:

```bash
git fetch consul
git merge consul/master
```

Tras el último comando, hay tres posibles escenarios:

A. Obtienes una respuesta `Already up-to-date.`. Eso significa que tu fork esta al dia con los cambios de consul 😊👌

B. Se abre una ventana del editor que tengas configurado en git, mostrando el mensaje de commit `Merge remote-tracking branch 'consul/master' into consul_pull`. Esto significa que git fue capaz de mezclar los cambios de consul sobre tu código sin encontrar problemas o conflictos. Termina el commit.

C. Recibes mensajes de error de git junto con un `Automatic merge failed; fix conflicts and then commit the result.`. Esto significa que se han encontrado conflictos entre los cambios en tu código y los cambios que se realizaron en consul desde la última vez que actualizaste tu fork. Esta es una de las principales razones para intentar mantener tu fork lo más al dia posible, realizando este proceso al menos mensualmente. Resuelve manualmente los conflictos para terminar el merge y haz un commit.

Now you can just simply push **consul_pull** branch to github and create a Pull Request so you can easily check all changes going into your repo, and see your tests suite runs.

Recuerda que siempre puedes comprobar rápidamente los cambios que tienes pendientes de integrar de consul a tu fork sustituyendo **your_org_name** en la url: https://github.com/your_org_name/consul/compare/master...consul:master
