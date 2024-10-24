# Personalización de rutas

Al añadir acciones de controlador personalizadas, necesitas definir una ruta que configure la URL que se usará para esas acciones. Puedes hacerlo editando el fichero `config/routes/custom.rb`.

Por ejemplo, para añadir una nueva sección al área de administración para gestionar pensamientos felices ("happy thoughts", en inglés) y verificar que se han hecho realidad, puedes escribir el siguiente código:

```ruby
namespace :admin do
  resources :happy_thoughts do
    member do
      put :verify
    end
  end
end
```

O, si, por ejemplo, quisieras añadir un formulario para editar debates en el área de administración:

```ruby
namespace :admin do
  resources :debates, only: [:edit, :update]
end
```

Al hacer esto, las rutas existentes de debates en el área de administración se mantendrán, y a ellas se añadirán las rutas "edit" y "update".

Las rutas que defines en este fichero tendrán precedencia sobre las rutas por defecto. Así que, si defines una ruta para `/proposals`, la acción por defecto para `/proposals` no se utilizará sino que en su lugar se usará la que definas tú.
