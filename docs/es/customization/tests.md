# Personalización de tests

Los tests comprueban que la aplicación se comporta de la manera esperada. Por esta razón, es **extremadamente importante** que escribas tests para todas las funcionalidades que añadas o modifiques. Sin tests, no tendrás una manera fiable de confirmar que la aplicación sigue comportándose correctamente cuando cambias el código o cuando actualizas a una nueva versión de Consul Democracy. Consul Democracy incluye más de 6000 tests que comprueban la manera en que se comporta la aplicación; sin ellos, sería imposible asegurarse de que el código nuevo no rompe comportamientos existentes.

Como ejecutar los tests en tu máquina de desarrollo puede llevar más de una hora, recomendamos [configurar tu "fork"](../getting_started/configuration.md) para que use un sistema de integración continua que ejecute todos los tests cada vez que hagas cambios en el código. Recomendamos ejecutar estos tests en una rama de desarrollo abriendo una "pull request" (también llamada "merge request") para que los tests se ejecuten antes de que los cambios personalizados se añadan a la rama `master`.

En caso de que alguno de los tests falle, echa un vistazo a uno de los tests y comprueba si falla por un fallo en el código personalizado o porque el test comprueba un comportamiento que ha cambiado con los cambios personalizados (por ejemplo, puede que modifiques el código para que solamente los usuarios verificados puedan añadir comentarios, pero puede que haya un test que compruebe que cualquier usuario puede añadir comentarios, ya que es el comportamiento por defecto). Si el test falla debido a un fallo en el código personalizado, arréglalo ;). Si falla debido a un comportamiento que ha cambiado, tendrás que cambiar el test.

Cambiar un test es un proceso que consiste en dos pasos:

1. Asegurarse de que el test que comprueba el comportamiento por defecto de Consul Democracy deja de ejecutarse
2. Escribir un nuevo test para el nuevo comportamiento

Para el primer paso, añade una etiqueta `:consul` al test o al bloque de tests. Como ejemplo, veamos este código:

```ruby
describe Users::PublicActivityComponent, controller: UsersController do
  describe "follows tab" do
    context "public interests is checked" do
      it "is displayed for everyone" do
        # (...)
      end

      it "is not displayed when the user isn't following any followables", :consul do
        # (...)
      end

      it "is the active tab when the follows filters is selected", :consul do
        # (...)
      end
    end

    context "public interests is not checked", :consul do
      it "is displayed for its owner" do
        # (...)
      end

      it "is not displayed for anonymous users" do
        # (...)
      end

      it "is not displayed for other users" do
        # (...)
      end

      it "is not displayed for administrators" do
        # (...)
      end
    end
  end
end
```

En el primer bloque de tipo "context", solamente el primer test se ejecutará. Los otros dos tests no se ejecutarán ya que contienen la etiqueta `:consul`.

El segundo bloque de tipo "context" contiene la etiqueta `:consul` en el propio bloque, con lo que ninguno de sus tests se ejecutarán.

Recuerda: cuando añadas una etiqueta `:consul` a un test porque la aplicación ya no se comporta como describe ese test, escribe un nuevo test comprobando el nuevo comportamiento. De no hacerlo, la probabilidad de que la gente que visita tu página se encuentre errores 500 (o, peor aún, errores de los que nadie se da cuenta) aumentará de manera drástica.

Para escribir un test personalizado, utiliza los directorios `custom` dentro de `spec/`:

* `spec/components/custom/`
* `spec/controllers/custom/`
* `spec/models/custom/`
* `spec/routing/custom/`
* `spec/system/custom/`
