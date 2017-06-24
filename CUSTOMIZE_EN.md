# Customization

You can modify your own Consul to have your custom visual style, but first you'll have to create a fork from [https://github.com/consul/consul](https://github.com/consul/consul) using Github's "fork" button on top right corner. You can use any other service like Gitlab, but don't forget to put a reference link back to Consul on the footer to comply with project's license (GPL Affero 3).

We've created an specific structure where you can overwrite and customize the application in a way that will let you keep updating it from Consul's main repository, without having conflicts on code merging or risking loosing your customization changes. We try to make Consul as vanilla as possible to help other developers onboard the codebase.

## Special Folders and Files

In order to customize your Consul fork, you'll make use of some `custom` folders on the following paths:

* `config/locales/custom/`
* `app/assets/images/custom/`
* `app/views/custom/`
* `app/controllers/custom/`
* `app/models/custom/`

Also these are the files where you can apply some customization:

* `app/assets/stylesheets/custom.css`
* `app/assets/stylesheets/_custom_settings.css`
* `app/assets/javascripts/custom.js`
* `Gemfile_custom`
* `config/application.custom.rb`

### Internationalization

If you want to add a new language translation of the user-facing texts you can find them organized in YML files under `config/locales/` folder. Take a look at the official Ruby on Rails [internationalization guide](http://guides.rubyonrails.org/i18n.html) to better understand the translations system.

If you just want to change some of the existing texts, you can just drop your changes at the `config/locales/custom/` folder, we strongly recommend to include only those text that you want to change instead of a whole copy of the original file. For example if you want to customize the text "Ayuntamiento de Madrid, 2016" that appears on every page's footer, firstly you want to locate where it's used (`app/views/layouts/_footer.html.erb`), we can see code is:

```ruby
<%= t("layouts.footer.copyright", year: Time.current.year) %>
```

And that the text its located at the file `config/locales/es.yml` following this structure (we're only displaying in the following snippet the relevant parts):

```yml
es:
  layouts:
    footer:
      copyright: Ayuntamiento de Madrid, %{year}

```

So in order to customize it, we would create a new file `config/locales/custom/es.yml` with just that content, and change "Ayuntamiento de Madrid" for our organization name. We strongly recommend to make copies from `config/locales/` and modify or delete the lines as needed to keep the indentation structure and avoid issues.

### Images

If you want to overwrite any image, firstly you need to findout the filename, and by defaul it will be located under `app/assets/images`. For example if you want to change the header logo (`app/assets/images/logo_header.png`) you must create another file with the exact same file name under `app/assets/images/custom` folder. The images and icons that you will most likely want to change are:

* apple-touch-icon-200.png
* icon_home.png
* logo_email.png
* logo_header.png
* map.jpg
* social-media-icon.png

### Views (HTML)

If you want to change any page HTML  you can just find the correct file under the `app/views` folder and put a copy at `app/views/custom` keeping as well any sub-folder structure, and then apply your customizations. For example if you want to customize `app/views/pages/conditions.html` you'll have to make a copy at `app/views/custom/pages/conditions.html.erb` (note the `pages` subdirectory).

### CSS

In order to make changes to any CSS selector (custom style sheets), you can add them directly at `app/assets/stylesheets/custom.scss`. For example to change the header color (`.top-links`) you can just add:

```css
.top-links {
  background: red;
}
```

If you want to change any [foundation](http://foundation.zurb.com/) variable, you can do it at the `app/assets/stylesheets/_custom_settings.scss` file. For example to change the main application color just add:

```css
$brand:             #446336;
```

We use [SASS, with SCSS syntax](http://sass-lang.com/guide) as CSS preprocessor.

### Javascript

If you want to add some custom Javascript code, `app/assets/javascripts/custom.js` is the file to do it. For example to create a new alert just add:

```js
$(function(){
  alert('foobar');
});
```

### Models

If you need to create new models or customize existent ones, you can do it so at the `app/models/custom` folder. Keep in mind that for old models you'll need to firstly require the dependency.

For example for Madrid's City Hall fork its required to check the zip code's format (it always starts with 280 followed by 2 digits). That check is at `app/models/custom/verification/residence.rb`:

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

Do not forget to cover your changes with a test at the `spec/models/custom` folder. Following the example we could create `spec/models/custom/residence_spec.rb`:

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

### Controllers

TODO!

### Gemfile

To add new gems (libraries) you can edit the `Gemfile_custom` file. For example to add [rails-footnotes](https://github.com/josevalim/rails-footnotes) gem you would just add:

```ruby
gem 'rails-footnotes', '~> 4.0'
```

And then just do the classic Ruby on Rails flow `bundle install` and following any gem specific install steps from it's own documentation.

### application.rb

If you need to extend or modify the `config/application.rb` just do it at the `config/application_custom.rb` file. For example if you want to change de default language to English, just add:

```ruby
module Consul
  class Application < Rails::Application
    config.i18n.default_locale = :en
    config.i18n.available_locales = [:en, :es]
  end
end
```

Remeber that in order to see this changes live you'll need to restart the server.

### lib/

TODO

### public/

TODO

### Seeds

TODO

## Updating

We recommend you to add consul as remote:

```
git remote add consul https://github.com/consul/consul
```

And then just grab lastest changes on to a branch of your own repo with:

```
git checkout -b consul_update
git pull consul master
```
