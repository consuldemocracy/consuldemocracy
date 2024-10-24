# Customizing translations and texts

## Translations

Currently, Consul Democracy is totally or partially translated to multiple languages. You can find the translations at the [Crowdin project](https://translate.consuldemocracy.org/).

Please [join the translators](https://crwd.in/consul) to help us complete existing languages, or contact us through [Consul Democracy's discussions](https://github.com/consuldemocracy/consuldemocracy/discussions) to become a proofreader and validate translators' contributions.

If your language isn't already present in the Crowdin project, please [open an issue](https://github.com/consuldemocracy/consuldemocracy/issues/new?title=New%20language&body=Hello%20I%20would%20like%20to%20have%20my%20language%20INSERT%20YOUR%20LANGUAGE%20NAME%20added%20to%20Consul%20Democracy) and we'll set it up in a breeze.

The existing translations of the user-facing texts are organized in YAML files under the `config/locales/` folder. Take a look at the official Ruby on Rails [internationalization guide](http://guides.rubyonrails.org/i18n.html) to better understand the translations system.

## Custom texts

Since Consul Democracy is always evolving with new features, and in order to make it easier to update your fork, we strongly recommend that translation files aren't modified, but instead "overwritten" with custom translation files in case you need to customize a text.

So, if you'd like to change some of the existing texts, you can add your changes to the `config/locales/custom/` folder. You should only include the texts you'd like to change instead of copying the original file. For example, if you'd like to customize the text "CONSUL DEMOCRACY, 2024" (or the current year) that appears on the footer of every page, first locate where it's used (in this case, `app/components/layouts/footer_component.html.erb`) and look at the locale identifier inside the code:

```erb
<%= t("layouts.footer.copyright", year: Time.current.year) %>
```

Then find the file where this identifier will be located (in this case, `config/locales/en/general.yml`), and create a file under `config/locales/custom/` (in this case, create a file named `config/locales/custom/en/general.yml`) with the following content:

```yml
en:
  layouts:
    footer:
      copyright: Your Organization, %{year}
```

Note that custom locale files should only include your custom texts and not the original texts. This way it'll be easier to upgrade to a new version of Consul Democracy.

## Maintaining your custom texts and languages

Consul Democracy uses the [i18n-tasks](https://github.com/glebm/i18n-tasks) gem, which is an awesome tool to manage translations. Run `i18n-tasks health` for a nice report.

If you have a custom language different than English, you should add it to both `base_locale` and `locales` variables in the [i18n-tasks.yml config file](https://github.com/consuldemocracy/consuldemocracy/blob/master/config/i18n-tasks.yml#L3-L6), so your language files will be checked as well.
