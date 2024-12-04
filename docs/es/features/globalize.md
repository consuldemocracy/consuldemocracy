# Globalize

Sigue estos pasos para añadir [Globalize](https://github.com/globalize/globalize) a un modelo de la aplicación (también se hace uso de la gema [`globalize_accessors`](https://github.com/globalize/globalize-accessors)).

## 1. Definir los atributos a traducir

Hay que definir los atributos que se quieran traducir en el modelo. Para ello, hay que añadir la opción `translates` seguida de los nombres de los atributos.

También deberemos añadir la opción `globalize_accessors` con todos aquellos locales a los que queramos tener acceso. Esta gema generará los métodos `title_en`, `title_es`, etc., y que se usan en la aplicación. Si lo que quieres es incluir **todos** los campos traducidos en **todos** los idiomas definidos en tu aplicación, puedes llamar a `globalize_accessors` sin ninguna opción (tal y como se explica en la [documentación](https://github.com/globalize/globalize-accessors#example)).

```ruby
# Suponiendo un modelo Post con attributos title y text

class Post < ActiveRecord::Base
  translates :title, :text
  globalize_accessors locales: [:en, :es, :fr, :nl, :val, :pt_br]
end
```

## 2. Crear la migración para generar la tabla de traducciones

Hay que crear una migración para generar la tabla donde se almacenarán todas las traducciones de ese modelo. La tabla deberá tener una columna por cada atributo que queramos traducir. Para migrar los datos ya almacenados (en la tabla original), hay que añadir la opción `:migrate_data => true` en la propia migración:

```ruby
class AddTranslatePost < ActiveRecord::Migration
  def self.up
    Post.create_translation_table!({
      title: :string,
      text: :text
    }, {
      :migrate_data => true
    })
  end

  def self.down
    Post.drop_translation_table! :migrate_data => true
  end
end
```

## 3. Añadir el módulo `Translatable`

Añadir el módulo `Translatable` en el controlador que vaya a gestionar las traducciones.

```ruby
class Post < Admin::BaseController
  include Translatable
...
```

Hay que asegurarse de que este controlador tiene las funciones `resource_model` y `resource`, que devuelven el nombre del modelo y el objeto para el que se van a gestionar las traducciones, respectivamente.

```ruby
...
  def resource_model
    Post
  end

  def resource
    @post = Post.find(params[:id])
  end
 ...
```

## 4. Añadir los parámetros de las traducciones a los parámetros permitidos

Añadir como parámetros permitidos aquellos que estén dedicados a las traducciones. Para eso, el módulo `Translatable` posee una función llamada `translation_params(params)`, a la que se le pasan el parámetro del objeto. A partir de esos parámetros, y teniendo en cuenta los idiomas definidos para ese modelo, la función devuelve aquellos parámetros que contengan un valor.

```ruby
# Siguiendo con el ejemplo, en este caso se le pasarían los parámetros params[:post], porque es el
# hash que contiene toda la información.

attributes = [:title, :description]
params.require(:post).permit(*attributes, translation_params(params[:post]))
```

## 5. Añadir los campos a traducir en los formularios

Añadir los campos a los formularios de creación y edición para poder crear las traducciones. Recordar que, para esto, existe una función en el helper que engloba la lógica de `Globalize.with_locale` en un bloque llamado `globalize(locale) do`.

Los campos que vayan a editar la información a traducir deberán llamarse `<nombre_attributo>_<locale>`, por ejemplo `title_en`, de manera que, cuando esa información llegue al servidor, el helper pueda clasificar los parametros.

Recuerda que, para evitar errores al usar locales como `pt-BR`, `es-ES`, etc. (aquellos cuya región está especificada por '-'), hay que utilizar la función `neutral_locale(locale)`, definida en el `GlobalizeHelper`. Esta función convierte este tipo de locales en minúsculas con guiones bajos, con lo que `pt-BR` pasará a ser `pt_br`. Este formato es compatible con `globalize_accessor`, al contrario que el oficial, puesto que los métodos generados tendrían el nombre `title_pt-BR`, que es un formato erróneo. Al usar esa función, el método pasará a llamarse `title_pt_br`, que es correcto, y, además, no genera conflictos en las vistas a la hora de comparar el locale `pt-BR` con el modificado `pt_br`. Se usará siempre el segundo.

## 6. Añadir los parámetros ocultos para borrar traducciones

Al formulario que se use para editar las traducciones se le deberá añadir el parámetro oculto que las marca para que se borren:

```erb
<%= hidden_field_tag "delete_translations[#{locale}]", 0 %>
```

También habrá que añadir el link de "Eliminar idioma", que deberá tener:

- un id con el formato `delete-<locale neutro>`, siendo "locale neutro" el resultado de la función `neutral_locale(locale)`.
- un atributo `data-locale` con el valor de `neutral_locale(locale)`.
- la clase `delete-language`.

```erb
<%= link_to t("admin.milestones.form.remove_language"), "#",
                id: "delete-#{neutral_locale(locale)}",
                class: 'delete-language',
                data: { locale: neutral_locale(locale) } %>
```

Los estilos de CSS y el resto de clases que se le quieran añadir dependerán de la interfaz que se haya diseñado para gestionar esas traducciones (si se debe ocultar o no dependiendo del idioma seleccionado, por ejemplo).

## 7. Añadir al `dev_seed` las traducciones del nuevo modelo

Para que se generen cuando se restablezca la base de datos. Por ejemplo, para crear un post cuya descripción está traducida:

```ruby
section "Creating post with translations" do
  post = Post.new(title: title)
  I18n.available_locales.map do |locale|
    neutral_locale = locale.to_s.downcase.underscore.to_sym
    Globalize.with_locale(neutral_locale) do
      post.description = "Description for locale #{locale}"
      post.save
    end
  end
end
```
