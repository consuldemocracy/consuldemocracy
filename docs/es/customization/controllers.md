# Personalización de controladores

Al igual que los modelos, los controladores están escritos en Ruby, con lo cual su personalización es similar solo que usaremos el directorio `app/controllers/custom/` en lugar del directorio `app/models/custom/`. Echa un vistazo a la documentación de [personalización de modelos](models.md) para más información.

## Personalización de parámetros permitidos

Al personalizar Consul Democracy, a veces querrás añadir un nuevo campo en un formulario. Además de [personalizar la vista](views.md) o [el componente](components.md) que renderiza ese formulario, tendrás que modificar el controlador para que acepte el nuevo campo. En caso contrario, el nuevo campo será ignorado completamente; esta práctica se utiliza para evitar [ataques de asignación masiva](https://en.wikipedia.org/wiki/Mass_assignment_vulnerability).

Por ejemplo, supongamos que has modificado el modelo `SiteCustomization::Page` para que utilice un campo llamado `author_nickname` y has añadido ese campo al formulario para crear una nueva página en el área de administración. Para añadir este campo a la lista de parámetros permitidos por el controlador, crea el archivo `app/controllers/custom/admin/site_customization/pages_controller.rb` con el siguiente contenido:

```ruby
load Rails.root.join("app", "controllers", "admin", "site_customization", "pages_controller.rb")

class Admin::SiteCustomization::PagesController

  private

    alias_method :consul_allowed_params, :allowed_params

    def allowed_params
      consul_allowed_params + [:author_nickname]
    end
end
```

Nótese cómo estamos creando un alias para el método original `allowed_params` y luego estamos llamando a ese alias. De esta manera, todos los parámetros permitidos por el código original también estarán permitidos en nuestro método personalizado.
