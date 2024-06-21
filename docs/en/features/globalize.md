# Globalize

Follow this steps to add [Globalize](https://github.com/globalize/globalize) to a model (the gem [`globalize_accessors`](https://github.com/globalize/globalize-accessors) is also used).

## 1. Define the attributes to be translated

We should add in the model the attributes that are going to be translated. To do that, use the `translates` option followed by the attribute names.

We also need to add the option `globalize_accessors` to include all the locales we want to support. This gem generates all the methods needed by the application (`title_en`, `title_es`, etc.). If you want to include **all** the translated fields in **all** the defined languages in your application, just call `globalize_accessors` without any option (as the [documentation](https://github.com/globalize/globalize-accessors#example) says).

```
# Supposing a model Post with title and text attributes

class Post < ActiveRecord::Base
  translates :title, :text
  globalize_accessors locales: [:en, :es, :fr, :nl, :val, :pt_br]
end
```

## 2. Create the migration to generate the translations table

We must create a migration to generate the table where the translations are going to be stored. The table must have a column for each attribute we want to translate. To migrate the stored data in the original table, add the option `:migrate_data => true` in the migration.

```
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

## 3. Add the `Translatable` module

Add the `Translatable` module in the controller that will handle the translations.

```
class PostController < Admin::BaseController
  include Translatable
...
```

Make sure that the controller has the functions `resource_model` and `resource`, which return the name of the model and the object we want to save the translations for, respectively.

```
...
  def resource_model
    Post
  end

  def resource
    @post = Post.find(params[:id])
  end
 ...
```

## 4. Add the translation params to the permitted params

Add as permitted params those dedicated to translations. To do that, the module `Translatable` owns a function called `translation_params(params)`, which will receive the object param and will return those keys with a value. It takes into account the languages defined for that model.

```
# Following the example, we pass the params[:post] because is the one that has the information.

attributes = [:title, :description]
params.require(:post).permit(*attributes, translation_params(params[:post]))
```

## 5. Add the fields in the form

Add the fields to the form for creating and editing the translations. Remember that, to do this, there is a function in the helper that encapsules the `Globalize.with_locale` logic in a block called `globalize(locale) do`.

The fields that are going to be translated should be named `<attribute_name>_<locale>`, for example `title_en`, so when that information arrives to the server, it can classify the parameters.

Remember that, to avoid errors when using locales like `pt-BR`, `es-ES`, etc. (those whose region is specified by a '-'), we must use a function called `neutral_locale(locale)`, defined in the `GlobalizeHelper`. This function converts this type of locales in lower case and underscored, so `pt-BR` will transform in `pt_br`. This format is compatible with `globalize_accessors`, whereas the official is not because the method names like `title_pt-BR` are not allowed. When using this function, the method will call `title_pt_br` and it will not generate conflicts when comparing `pt-BR` with `pt_br`.

## 6. Add hidden parameters to delete translations

Add the hidden parameters to the form to delete translations:

```
<%= hidden_field_tag "delete_translations[#{locale}]", 0 %>
```

We must add the link "Remove translation" to delete translations, which should have:

- an id with this format: `delete-<neutral locale>`, where "neutral locale" is the result of the function `neutral_locale(locale)`.
- an attribute `data-locale` with the value of `neutral_locale(locale)`.
- the class `delete-language`.

```
<%= link_to t("admin.milestones.form.remove_language"), "#",
                id: "delete-#{neutral_locale(locale)}",
                class: 'delete-language',
                data: { locale: neutral_locale(locale) } %>
```

The CSS styles and the rest of the classes will depend on the designed UI for that translations (if the link should show or hide, for example).

## 7. Add the translations for the new model to the `dev_seed`

So that they will be generated when the DB is restored. For example, to create a post whose description is translated.

```
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