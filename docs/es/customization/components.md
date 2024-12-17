# Personalización de componentes

En el caso de los componentes, la personalización puede utilizarse para cambiar tanto la lógica (incluida en un archivo `.rb`) como la vista (incluida en un archivo `.erb`). Si solo quieres personalizar la lógica, por ejemplo del componente `Admin::TableActionsComponent`, crea el archivo `app/components/custom/admin/table_actions_component.rb` con el siguiente contenido:

```ruby
load Rails.root.join("app", "components", "admin", "table_actions_component.rb")

class Admin::TableActionsComponent
  # Tu lógica personalizada aquí
end
```

Consulta la sección de [personalización de modelos](models.md) para más información sobre personalizar clases de Ruby.

Si, por el contrario, también quieres personalizar la vista, necesitas una pequeña modificación. En lugar del código anterior, utiliza:

```ruby
class Admin::TableActionsComponent < ApplicationComponent; end

load Rails.root.join("app", "components", "admin", "table_actions_component.rb")

class Admin::TableActionsComponent
  # Tu lógica personalizada aquí
end
```

Esto hará que el componente utilice la vista en `app/components/custom/admin/table_actions_component.html.erb`. Puedes crear este archivo y personalizarlo según tus necesidades, de la misma manera en que puedes [personalizar vistas](views.md).
