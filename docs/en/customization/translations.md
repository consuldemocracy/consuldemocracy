# Translations and Texts

## Translations

Currently, Consul Democracy is totally or partially translated to multiple languages. You can find the translations at the [Crowdin project](https://crowdin.com/project/consul).

Please [join the translators](https://crwd.in/consul) to help us complete existing ones, or contact us through [Consul Democracy's gitter](https://gitter.im/consul/consul) to become a proofreader and validate translators' contributions.

If your language isn't already present in the Crowdin project, please [open an issue](https://github.com/consul/consul/issues/new?title=New language&body=Hello I would like to have my language INSERT YOUR LANGUAGE NAME added to Consul Democracy) and we'll set it up in a breeze.

If you want to check existing translations of the user-facing texts you can find them organized in YML files under `config/locales/` folder. Take a look at the official Ruby on Rails [internationalization guide](http://guides.rubyonrails.org/i18n.html) to better understand the translations system.

## Custom Texts

Since Consul Democracy is always evolving with new features, and in order to make your fork easier to be updated, we strongly recommend translation files not to be modified, but instead "overwritten" with custom translation files in case a text needs to be customized for you.

So if you just want to change some of the existing texts, you can just drop your changes at the `config/locales/custom/` folder. We strongly recommend to include only those texts that you want to change instead of a whole copy of the original file. For example if you want to customize the text "Ayuntamiento de Madrid, 2016" that appears on every page's footer, firstly you want to locate where it's used (`app/views/layouts/_footer.html.erb`) and look at the locale identifier inside the code:

```ruby
<%= t("layouts.footer.copyright", year: Time.current.year) %>
```

Then find the file where this identifier will be located (in that case `config/locales/es/general.yml`) following this structure (we're only displaying the relevant parts in the following snippet):

```yml
es:
  layouts:
    footer:
      copyright: Ayuntamiento de Madrid, %{year}
```

In order to customize it, you should create a new file `config/locales/custom/es/general.yml` with just that content, and change "Ayuntamiento de Madrid" with our organization name. We strongly recommend to make copies from `config/locales/` and modify or delete the lines as needed to keep the indentation structure and avoid issues.

## Maintaining your Custom Texts & Languages

Consul Democracy has the [i18n-tasks](https://github.com/glebm/i18n-tasks) gem, it's an awesome helping tool to manage i18n translations. Just check `i18n-tasks health` for a nice report.

If you have a custom language different than English, you should add it to the [i18n-tasks.yml config file both `base_locale` and `locales`](https://github.com/consul/consul/blob/master/config/i18n-tasks.yml#L4-L7) variables so your language files will be checked as well.
