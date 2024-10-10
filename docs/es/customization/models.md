# Personalización de modelos

Si quieres agregar modelos nuevos, o modificar o agregar métodos a uno ya existente, puedes utilizar el directorio `app/models/custom/`.

Si estás añadiendo un nuevo modelo que no existe en el código original de Consul Democracy, simplemente añade el modelo a ese directorio.

Si, por el contrario, estás cambiando un modelo que existe en la aplicación, crea un fichero en `app/models/custom/` con el mismo nombre que el fichero que estás cambiando. Por ejemplo, para cambiar el fichero `app/models/budget/investment.rb`, crea un fichero llamado `app/models/custom/budget/investment.rb` que cargue el original:

```ruby
load Rails.root.join("app", "models", "budget", "investment.rb")

class Budget
  class Investment
  end
end
```

Como el fichero personalizado carga el original, con este código el modelo personalizado se comportará exactamente igual que el original.

Nótese que, si no se carga el fichero original, el modelo personalizado no hará nada, lo cual hará que la aplicación no se comporte correctamente.

## Añadir nuevos métodos

Para añadir un método nuevo, simplemente añade el nuevo código al modelo. Por ejemplo, para añadir un método de tipo "scope" que devuelva los proyectos de gasto creados durante el último mes:

```ruby
load Rails.root.join("app", "models", "budget", "investment.rb")

class Budget
  class Investment
    scope :last_month, -> { where(created_at: 1.month.ago..) }
  end
end
```

Con este código, el modelo personalizado tendrá todos los métodos del modelo original (ya que carga el archivo original) más el método de tipo "scope" `last_month`.

## Modificar métodos existentes

Al modificar métodos existentes, recomendamos encarecidamente que, siempre que sea posible, **tu código personalizado llame al código original** y solamente modifique los casos en que debería comportarse de forma diferente. De este modo, al actualizar a una nueva versión de Consul Democracy que actualice los métodos originales, tus métodos personalizados incluirán las modificaciones del código original automáticamente. En ocasiones, hacer esto no será posible, con lo cual tendrás que cambiar tu método personalizado al actualizar.

Por ejemplo, para cambiar el modelo `Abilities::Common` para que solamente los usuarios verificados puedan crear comentarios, crearemos el archivo `app/models/custom/abilities/common.rb` con el siguiente contenido:

```ruby
load Rails.root.join("app", "models", "abilities", "common.rb")

module Abilities
  class Common
    alias_method :consul_initialize, :initialize # create a copy of the original method

    def initialize(user)
      consul_initialize(user) # call the original method
      cannot :create, Comment # undo the permission added in the original method

      if user.level_two_or_three_verified?
        can :create, Comment
      end
    end
  end
end
```

Puedes encontrar otro ejemplo de modelo personalizado en el archivo `app/models/custom/setting.rb`.
