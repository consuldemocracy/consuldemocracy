# Translations

Currently Consul is translated totally or partially to multiple languages, check it's [Crowdin project](https://crowdin.com/project/consul)

Please [join the translators](https://crwd.in/consul) to add a new language or help complete existing ones, or contact us through [consul's gitter](https://gitter.im/consul/consul) to become a Proofreader and validate translators contributions.

If you want to check translations of the user-facing texts you can find them organized in YML files under `config/locales/` folder. Take a look at the official Ruby on Rails [internationalization guide](http://guides.rubyonrails.org/i18n.html) to better understand the translations system.

# Texts

If you just want to change some of the existing texts, you can just drop your changes at the `config/locales/custom/` folder, we strongly recommend to include only those text that you want to change instead of a whole copy of the original file. For example if you want to customize the text "Ayuntamiento de Madrid, 2016" that appears on every page's footer, firstly you want to locate where it's used (`app/views/layouts/_footer.html.erb`), we can see code is:

```ruby
<%= t("layouts.footer.copyright", year: Time.current.year) %>
```

And that the text its located at the file `config/locales/es/general.yml` following this structure (we're only displaying in the following snippet the relevant parts):

```yml
es:
  layouts:
    footer:
      copyright: Ayuntamiento de Madrid, %{year}

```

So in order to customize it, we would create a new file `config/locales/custom/es/general.yml` with just that content, and change "Ayuntamiento de Madrid" for our organization name. We strongly recommend to make copies from `config/locales/` and modify or delete the lines as needed to keep the indentation structure and avoid issues.
