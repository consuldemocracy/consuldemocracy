# Customization

You can modify your own CONSUL to have your custom visual style, but first you'll have to [create your own fork from](../getting_started/create.md).

We've created an specific structure where you can overwrite and customize the application in a way that will let you keep updating it from CONSUL's main repository, without having conflicts on code merging or risking loosing your customization changes. We try to make CONSUL as vanilla as possible to help other developers onboard the codebase.

## Special Folders and Files

In order to customize your CONSUL fork, you'll make use of some `custom` folders on the following paths:

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

## Remote translations on demand by the user

The aim of this service is to be able to offer all the dynamic contents of the application (proposals, debates, budget investments and comments) in different languages without the need for a user or administrator to have created each one of their translations.

When a user visits a page with a language where there is untranslated content, they will have a button to request the translation of all the content. This content will be sent to an automatic translator (in this case [Microsoft TranslatorText](https://azure.microsoft.com/en-us/products/cognitive-services/translator/)) and as soon as the response is obtained, all these translations will be available to any user.

### Getting started
In order to use this functionality, the following steps are necessary:
1. Have an api key to connect to the translation service. For this we need an [Azure account](https://azure.microsoft.com/en-us/)
1. Once you are logged into the Azure portal, subscribe to the Translator in Cognitive Service.
1. Once you have subscribed to the Translator Text service, you will have access to 2 api keys in the section **Resource Management > Keys and Endpoint** that will be necessary for the configuration of the translation service in your application.

### Configuration
To activate the translation service in your application you must complete the following steps:

#### Add api key in the application
In the previous section we have commented that once subscribed to the translation service we have 2 api keys. To configure the service correctly in our application we must add one of the two api keys in the file `secrets.yml` in section `apis:` with the key `microsoft_api_key` as we can see in the following image:

![Add api key to secrets](../../img/translations/remote_translations/add-api-key-to-secrets.png)

#### Activate module
Once we have the new key in the `secrets.yml` we can now proceed to activate the module. To activate the functionality you must follow 2 steps:
1. Execute the following command `bin/rake settings:create_remote_translations_setting RAILS_ENV=production`
1. Accessing through the administration panel of your application to the section **Configuración > Funcionalidades** and activate module **Traducciones Remotas** as shown below:
![Active remote translations](../../img/translations/remote_translations/active-remote-translations-en.png)

### Use Cases
Once we have the api key in our `secrets.yml` and the activated module, users will already be able to use the functionality.
We attach some screenshots of how the application interacts with our users:
* When a user visits a page in a language without translated content, an informative text will appear at the top of the page and a button to request the translation. (**Note:** *If user visit page with a language not supported by the translation service, no text or translation button will be displayed. See section: Available languages for remote translation*)
![Display text and button](../../img/translations/remote_translations/display-text-and-button-en.png)

* Once the user click the `Translate page` button, the translations are enqueued and the page is reloaded with a notice (*Informing that the translations have been requested correctly*) and an informative text in the header (*explaining when you will be able to see these translations*).
![Display notice and text after enqueued translations](../../img/translations/remote_translations/display-notice-and-text-after-enqueued-en.png)

* If an user visit a page that does not have translations but have already been requested by another user. The application will not show you the translate button, but an informative text in the header (*explaining when you will be able to see these translations*).
![Display text explaining that translations are pending](../../img/translations/remote_translations/display-text-translations-pending-en.png)

* The translation request, response processing and data saving are delegated to `Delayed Jobs` and as soon as they are processed, the user will be able to read them after page refresh.
![Display translated content](../../img/translations/remote_translations/display-translated-content-en.png)

### Available languages for remote translation
Currently these are all the [available languages](https://api.cognitive.microsofttranslator.com/languages?api-version=3.0) in the translation service:
```yml
["af", "am", "ar", "as", "az", "ba", "bg", "bn", "bo", "bs", "ca", "cs", "cy", "da", "de", "dv", "el", "en", "es", "et", "eu", "fa", "fi", "fil", "fj", "fo", "fr", "fr-CA", "ga", "gl", "gu", "ha", "he", "hi", "hr", "hsb", "ht", "hu", "hy", "id", "ig", "ikt", "is", "it", "iu", "iu-Latn", "ja", "ka", "kk", "km", "kmr", "kn", "ko", "ku", "ky", "ln", "lo", "lt", "lug", "lv", "lzh", "mg", "mi", "mk", "ml", "mn-Cyrl", "mn-Mong", "mr", "ms", "mt", "mww", "my", "nb", "ne", "nl", "nso", "nya", "or", "otq", "pa", "pl", "prs", "ps", "pt", "pt-PT", "ro", "ru", "run", "rw", "sk", "sl", "sm", "sn", "so", "sq", "sr-Cyrl", "sr-Latn", "st", "sv", "sw", "ta", "te", "th", "ti", "tk", "tlh-Latn", "tlh-Piqd", "tn", "to", "tr", "tt", "ty", "ug", "uk", "ur", "uz", "vi", "xh", "yo", "yua", "yue", "zh-Hans", "zh-Hant", "zu"]
```
Of all the languages that Consul currently has defined (`available_locales`) in `config/application.rb` the only one that is not listed above and therefore no translation service is offered is Valencian `["val"]`.

### Pricing
The translation service used has the most competitive [pricing](https://azure.microsoft.com/en-us/pricing/details/cognitive-services/translator/).
The price for each 1 Million characters translated is $10 and there is no fixed cost per month.

Although technical measures have been taken to prevent misuse of this service, we recommend the creation of Alerts offered by Azure so that an Administrator can be notified in the event of detecting unusual use of the service. This service has a cost of $0.10 per month.

To create an Alert in Azure we must follow the following steps:
1. Sign in to the **Azure Portal**.
1. Access the **Translator** service created earlier.
1. Go to **Monitoring > Alerts** in the side menu:
  1. Go to **Create alert rule**.
  1. In **Select a signal** select `Text Characters Translated`.
  1. Once selected we must define the logic of the Alert to suit our needs. Ex: Fill "Operator" field with "Greater than" option, fill "Aggregation type" field with "Total" option and fill "Threshold value" field with the number of characters we consider should be translated before being notified. In this section you can also set the time period and frequency of evaluation.
  1. In order to be notified we have to create an **Action Group** and associate it with this Alert we're creating. To do this, access the button **Create** and fill out the form. As you can see there are different types of actions, we must select **Email/SMS/Push/Voice** and configure the option that we consider convenient according to our needs.
  1. Once this group of actions has been created, it is directly associated with the rule we are creating.
  1. Finally, all you have to do is add a name and click on the **Review + create**

### Add a new translation service
If you want to integrate more translation services for any reason (new translation service appears, you want to change to include languages that are currently not supported, etc.) the code is ready to be added.
This is made possible by the `RemoteTranslations::Caller` class which is an intermediate layer between untranslated content management and the currently used Microsoft Translation Client.
A good solution for adding another translation service would be to replace the call to the `MicrosoftTranslateClient` in the `translations` method of `RemoteTranslations::Caller` with the new service implemented.
If you want to coexist with both should only be managed in which case we want to use one or the other, either through specific conditions in the code or through a management in the Settings of the application.

```ruby
class RemoteTranslationsCaller

  ...
  def translations
    @translations ||= RemoteTranslations::Microsoft::Client.new.call(fields_values, locale)
    # Add new RemoteTranslations Client
    # @translations = RemoteTranslations::NewTranslateClient::Client.new.call(fields_values, locale_to)
  end
  ...

end
```

## Translation interface

The aim of this feature is to allow users the introduction of dynamic contents in many languages at the same time. From the administration panel you can activate or deactivate it. If you deactivate this feature (default configuration) users will be able to enter one single translation.

### Enable module
To activate this feature you must follow 2 steps:
1. Execute the following command `bin/rake settings:create_translation_interface_setting RAILS_ENV=production` (This is only required for already existing intallations, for new consul installations this step is not needed).
2. Accessing as administrator user to the administration panel of your Consul application to the section **Configuration > Features** and activating the feature called **Translation Interface** as you can see next:
![Active interface translations](../../img/translations/interface_translations/active-interface-translations-en.png)

### Use Cases

* When the translation interface is active:
As you can see in the image below translation interface has two selectors, the first one "Select language" is to switch between enabled languages and the second one "Add language" is to add new languages to the form. Translatable fields appears with a blue background to facilitate users to distinguish between translatable and not translatable fields. Additionally interface provides a link `Remove language` to delete the current language shown at "Select language". If a user accidentally removes a translation he can recover it re-adding it to the form.
This feature is visible during creation and edition of translatable resources.
![Translations interface enabled](../../img/translations/interface_translations/translations-interface-enabled-en.png)

* When the translation interface is disabled:
When this feature is deactivated users will see standard forms without translation interface and without translation highlight.
![Translations interface enabled](../../img/translations/interface_translations/translations-interface-disabled-en.png)
