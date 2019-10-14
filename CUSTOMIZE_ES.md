# Personalización

Puedes modificar consul y ponerle tu propia imagen, para esto debes primero hacer un fork de [https://github.com/consul/consul](https://github.com/consul/consul) creando un repositorio nuevo en Github. Puedes usar otro servicio como Gitlab, pero no te olvides de poner el enlace en el footer a tu repositorio en cumplimiento con la licencia de este proyecto (GPL Affero 3).

Hemos creado una estructura específica donde puedes sobreescribir y personalizar la aplicación para que puedas actualizar sin que tengas problemas al hacer merge y se sobreescriban por error tus cambios. Intentamos que Consul sea una aplicación Ruby on Rails lo más plain vanilla posible para facilitar el acceso de nuevas desarrolladoras.

## Ficheros y directorios especiales

Para adaptarlo puedes hacerlo a través de los directorios que están en custom dentro de:

* `config/locales/custom/`
* `app/assets/images/custom/`
* `app/views/custom/`
* `app/controllers/custom/`
* `app/models/custom/`

Aparte de estos directorios también cuentas con ciertos ficheros para:

* `app/assets/stylesheets/custom.css`
* `app/assets/stylesheets/_custom_settings.css`
* `app/assets/javascripts/custom.js`
* `Gemfile_custom`
* `config/application.custom.rb`

### Internacionalización

Si quieres modificar algún texto de la web deberías encontrarlos en los ficheros formato YML disponibles en `config/locales/`. Puedes leer la [guía de internacionalización](http://guides.rubyonrails.org/i18n.html) de Ruby on Rails sobre como funciona este sistema.

Las adaptaciones los debes poner en el directorio `config/locales/custom/`, recomendamos poner solo los textos que quieras personalizar. Por ejemplo si quieres personalizar el texto de "Ayuntamiento de Madrid, 2016" que se encuentra en el footer en todas las páginas, primero debemos ubicar en que plantilla se encuentra (`app/views/layouts/_footer.html.erb`), vemos que en el código pone lo siguiente:

```ruby
<%= t("layouts.footer.copyright", year: Time.current.year) %>
```

Y que en el fichero `config/locales/es.yml` sigue esta estructura (solo ponemos lo relevante para este caso):

```yml
es:
  layouts:
    footer:
      copyright: Ayuntamiento de Madrid, %{year}

```

Si creamos el fichero `config/locales/custom/es.yml` y modificamos "Ayuntamiento de Madrid" por el nombre de la organización que se este haciendo la modificación. Recomendamos directamente copiar los ficheros `config/locales/` e ir revisando y corrigiendo las que querramos, borrando las líneas que no querramos traducir.

### Imágenes

Si quieres sobreescribir alguna imagen debes primero fijarte el nombre que tiene, por defecto se encuentran en `app/assets/images`. Por ejemplo si quieres modificar `app/assets/images/logo_header.png` debes poner otra con ese mismo nombre en el directorio `app/assets/images/custom`. Los iconos que seguramente quieras modificar son:

* apple-touch-icon-200.png
* icon_home.png
* logo_email.png
* logo_header.png
* map.jpg
* social-media-icon.png

### Vistas (HTML)

Si quieres modificar el HTML de alguna página puedes hacerlo copiando el HTML de `app/views` y poniendolo en `app/views/custom` respetando los subdirectorios que encuentres ahí. Por ejemplo si quieres modificar `app/views/pages/conditions.html` debes copiarlo y modificarla en `app/views/custom/pages/conditions.html.erb`

### CSS

Si quieres cambiar algun selector CSS (de las hojas de estilo) puedes hacerlo en el fichero `app/assets/stylesheets/custom.scss`. Por ejemplo si quieres cambiar el color del header (`.top-links`) puedes hacerlo agregando:

```css
.top-links {
  background: red;
}
```
Si quieres cambiar alguna variable de [foundation](http://foundation.zurb.com/) puedes hacerlo en el fichero `app/assets/stylesheets/_custom_settings.scss`. Por ejemplo para cambiar el color general de la aplicación puedes hacerlo agregando:

```css
$brand:             #446336;
```

Usamos un preprocesador de CSS, [SASS, con la sintaxis SCSS](http://sass-lang.com/guide).

### Javascript

Si quieres agregar código Javascript puedes hacerlo en el fichero `app/assets/javascripts/custom.js`. Por ejemplo si quieres que salga una alerta puedes poner lo siguiente:

```js
$(function(){
  alert('foobar');
});
```

### Modelos

Si quieres agregar modelos nuevos, o modificar o agregar métodos a uno ya existente puedes hacerlo en `app/models/custom`. En el caso de los modelos antiguos debes primero hacer un require de la dependencia.

Por ejemplo en el caso del Ayuntamiento de Madrid se requiere comprobar que el código postal durante la verificación sigue un cierto formato (empieza con 280). Esto se realiza creando este fichero en `app/models/custom/verification/residence.rb`:

```ruby
require_dependency Rails.root.join('app', 'models', 'verification', 'residence').to_s

class Verification::Residence

  validate :postal_code_in_madrid
  validate :residence_in_madrid

  def postal_code_in_madrid
    errors.add(:postal_code, I18n.t('verification.residence.new.error_not_allowed_postal_code')) unless valid_postal_code?
  end

  def residence_in_madrid
    return if errors.any?

    unless residency_valid?
      errors.add(:residence_in_madrid, false)
      store_failed_attempt
      Lock.increase_tries(user)
    end
  end

  private

    def valid_postal_code?
      postal_code =~ /^280/
    end

end
```

No olvides poner los tests relevantes en `spec/models/custom`, siguiendo con el ejemplo pondriamos lo siguiente en `spec/models/custom/residence_spec.rb`:


```ruby
require 'rails_helper'

describe Verification::Residence do

  let(:residence) { build(:verification_residence, document_number: "12345678Z") }

  describe "verification" do

    describe "postal code" do
      it "should be valid with postal codes starting with 280" do
        residence.postal_code = "28012"
        residence.valid?
        expect(residence.errors[:postal_code].size).to eq(0)

        residence.postal_code = "28023"
        residence.valid?
        expect(residence.errors[:postal_code].size).to eq(0)
      end

      it "should not be valid with postal codes not starting with 280" do
        residence.postal_code = "12345"
        residence.valid?
        expect(residence.errors[:postal_code].size).to eq(1)

        residence.postal_code = "13280"
        residence.valid?
        expect(residence.errors[:postal_code].size).to eq(1)
        expect(residence.errors[:postal_code]).to include("In order to be verified, you must be registered in the municipality of Madrid.")
      end
    end

  end

end
```

### Controladores

TODO

### Gemfile

Para agregar librerías (gems) nuevas puedes hacerlo en el fichero `Gemfile_custom`. Por ejemplo si quieres agregar la gema [rails-footnotes](https://github.com/josevalim/rails-footnotes) debes hacerlo agregandole

```ruby
gem 'rails-footnotes', '~> 4.0'
```

Y siguiendo el flujo clásico en Ruby on Rails (`bundle install` y seguir con los pasos específicos de la gema en la documentación)

### application.rb

Cuando necesites extender o modificar el `config/application.rb` puedes hacerlo a través del fichero `config/application_custom.rb`. Por ejemplo si quieres modificar el idioma por defecto al inglés pondrías lo siguiente:


```ruby
module Consul
  class Application < Rails::Application
    config.i18n.default_locale = :en
    config.i18n.available_locales = [:en, :es]
  end
end
```

Recuerda que para ver reflejado estos cambios debes reiniciar el servidor de desarrollo.

### lib/

TODO

### public/

TODO

### Seeds

TODO

## Actualizar

Te recomendamos que agregues el remote de consul para facilitar este proceso de merge:

```
$ git remote add consul https://github.com/consul/consul
```

Con esto puedes actualizarte con

```
git checkout -b consul_update
git pull consul master
```
