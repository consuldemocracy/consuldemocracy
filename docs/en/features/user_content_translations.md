# Translations of user content

## Remote translations on demand by the user

The aim of this service is to be able to offer all the dynamic contents of the application (proposals, debates, budget investments and comments) in different languages automatically.

When a user visits a page with a language where there is untranslated content, they will have a button to request the translation of all the content. This content will be sent to an automatic translator (as) and as soon as the response is obtained, all these translations will be available to any user.

### Selecting your translations provider

You can choose 2 different approaches to enable content translation, depending on your preference.

#### Microsoft TranslatorText Translation

* Probably preferable if you are already and Azure customer or when you prefer a dedicated translation API.

#### LLM Translation

* Probably preferable if when you already provision an LLM (AI) service, or when you want to take more control of your translations - customizing the translation prompt.

### Using Microsoft TranslatorText Translation

#### Getting started

In order to use this functionality, the following steps are necessary:

1. Create an [Azure account](https://azure.microsoft.com/en-us/).
2. Once you are logged into the Azure portal, create a resource of type _Translator Text_ (note: for this implementation it is necessary to select the GLOBAL region when creating the resource, otherwise it will be necessary to customize the API calls by adding the selected region).
3. Once you have subscribed to the Translator Text service, you will have access to two API keys in the section **Resource Management > Keys and Endpoint** that will be necessary for the configuration of the translation service in your application.

#### Configuration

To enable the translation service in your application you must complete the following steps:

##### Add api key in the application

In the previous section we have mentioned that, once subscribed to the translation service, we get two API keys. To configure the service correctly in our application we must add one of the two API keys to the `apis:` section of the `secrets.yml` file, with the key `microsoft_api_key` as follows:

```yml
apis: &apis
  census_api_end_point: ""
  census_api_institution_code: ""
  census_api_portal_code: ""
  census_api_user_code: ""
  sms_end_point: ""
  sms_username: ""
  sms_password: ""
  microsoft_api_key: "new_api_key_1_for_translator_text"
```

##### Enabling the feature

Once we have the new key in the `secrets.yml` we can now proceed to enable the feature. To enable it, in the administration area access the section **Settings > Global settings > Features** and enable the **Remote translation** feature.

#### Available languages for remote translation

Currently these are all the [available languages](https://api.cognitive.microsofttranslator.com/languages?api-version=3.0) in the translation service:

```yml
["af", "am", "ar", "as", "az", "ba", "bg", "bho", "bn", "bo", "brx", "bs", "ca", "cs", "cy", "da", "de", "doi", "dsb", "dv", "el", "en", "es", "et", "eu", "fa", "fi", "fil", "fj", "fo", "fr", "fr-CA", "ga", "gl", "gom", "gu", "ha", "he", "hi", "hne", "hr", "hsb", "ht", "hu", "hy", "id", "ig", "ikt", "is", "it", "iu", "iu-Latn", "ja", "ka", "kk", "km", "kmr", "kn", "ko", "ks", "ku", "ky", "ln", "lo", "lt", "lug", "lv", "lzh", "mai", "mg", "mi", "mk", "ml", "mn-Cyrl", "mn-Mong", "mni", "mr", "ms", "mt", "mww", "my", "nb", "ne", "nl", "nso", "nya", "or", "otq", "pa", "pl", "prs", "ps", "pt", "pt-PT", "ro", "ru", "run", "rw", "sd", "si", "sk", "sl", "sm", "sn", "so", "sq", "sr-Cyrl", "sr-Latn", "st", "sv", "sw", "ta", "te", "th", "ti", "tk", "tlh-Latn", "tlh-Piqd", "tn", "to", "tr", "tt", "ty", "ug", "uk", "ur", "uz", "vi", "xh", "yo", "yua", "yue", "zh-Hans", "zh-Hant", "zu"]
```

Of all the languages currently available in Consul Democracy (`available_locales`) in `config/application.rb`, the only one that is not listed above and therefore no translation service is offered is Valencian `["val"]`.

#### Pricing

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

### Using LLM Translation

#### Getting started

In order to use this functionality, the following steps are necessary:

1. Create an account with your LLM provider of choice (OpenAI, Anthropic, ...), or set up a self-hosted Ollama LLM endpoint.
2. Obtain an authentication / API key for the service. This step differs for each provider, so you will have to look it up yourself.

#### Configuration

To enable the translation service in your application you must complete the following steps:

##### Add api key in the application's credentials

Once your LLM API credentials are available, you have to configure your application secrets by using the section `apis:` and subsection `llm:` of the `secrets.yml` file, with the key `{provider}_api_key` as follows:

* Add a `llm:` subsection into the `apis:` subsection:

```yml
apis: &apis
  llm:
    # Provide keys for the LLM providers you intend to use.
    # consult RubyLLM https://rubyllm.com/configuration#global-configuration-rubyllmconfigure configuration for all supported providers and use the same key names here.
    deepseek_api_key: "1234567890"
```

##### Configuring LLM provider, model

Boot up your application, then navigate to Admin > Global Settings and choose LLM Settings tab. Your provider and the model to use for translations can be selected here.

![Display LLM configuration](../../img/translations/remote_translations/display-llm-translations-en.png)

If you have configured LLM credentials in `secrets.yml` file, but that provider is still disabled on the dropdown list, you are missing some [required fields for your provider](https://rubyllm.com/configuration#global-configuration-rubyllmconfigure).

##### Configuring LLM prompt

Use `config/llm_prompts.yml` and edit `remote_translation_prompt` to set up your own translation prompt. Ensure that the prompt returns the resulting translation as it's expected to be viewed by the end user.

##### Enabling the feature

Once we have configured everything in LLM Settings tab, we can proceed to enable the feature. To enable it, in the administration area access the section **Settings > Global settings > Features** and enable the **Remote translation** feature.

#### Pricing

Different LLM providers use different pricing strategies, but they are almost always based on input and output token usage. We can estimate 1 token = ~4 characters of text. The text to translate, along with translation prompt, will count towards input tokens, and the translated result towards output token count. Following this logic, translating 1 Million characters consumes about ~250k tokens as input and ~250k tokes as an output.

### Use Cases

Once we have feature set up and enabled, users will now be able to use remote translations in the application.

We attach some screenshots of how the application interacts with our users:

* When a user visits a page in a language without translated content, an informative text will appear at the top of the page next to a button to request the translation. (**Note:** *If a user visits a page with a language not supported by the translation service, no text or translation button will be displayed. See section: Available languages for remote translation*)

  ![The text "The content of this page is not available in your language" is displayed next to a "Translate page" button at the top of the page](../../img/translations/remote_translations/display-text-and-button-en.png)

* Once the user clicks the `Translate page` button, the translations are enqueued and the page is reloaded with a notice (*informing that the translations have been requested correctly*) and an informative text in the header (*explaining when you will be able to see these translations*).

  ![Display notice and text after enqueued translations](../../img/translations/remote_translations/display-notice-and-text-after-enqueued-en.png)

* If a user visits a page that does not have translations but its translations have already been requested by another user, the application will not show the translate button but an informative text in the header (*explaining when you will be able to see these translations*).

  ![Display text explaining that translations are pending](../../img/translations/remote_translations/display-text-translations-pending-en.png)

* The translation request, response processing and data saving are processed by background jobs and, as soon as they've finished, the user will be able to read them after refreshing the page.

  ![Display translated content](../../img/translations/remote_translations/display-translated-content-en.png)

### Add a new translation service

If you want to integrate more translation services for any reason (new translation service appears, you want to change to include languages that are currently not supported, etc.) the code is ready to be customized.

This is made possible by the `RemoteTranslations::Caller` class which is an intermediate layer between untranslated content management and the currently used Microsoft Translation Client.

A good solution for adding another translation service would be to replace the call to the `MicrosoftTranslateClient` in the `translations` method of `RemoteTranslations::Caller` with the new service implemented.

If you want to manage the coexistence of both, you should determine under which conditions to use one service or the other, either through specific conditions in the code or through a management in the Settings of the application.

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

The aim of this feature is to allow users the introduction of dynamic contents in many languages at the same time. From the administration panel you can enable or disable it. If you disable this feature (default configuration) users will be able to enter one single translation.

### Enabling the feature

To enable this feature you must access from the administration panel to the section **Configuration > Global configuration > Features** and enable the feature called **Translation Interface**.

### Use Cases

Depending on whether we enable or disable the **Translation Interface** feature we will see the forms as follows:

* When the translation interface is active:
  As you can see in the image below, the translation interface has two selectors, the first one "Select language" is to switch between enabled languages and the second one "Add language" is to add new languages to the form. Translatable fields appears with a blue background to facilitate users to distinguish between translatable and not translatable fields.

  Additionally, the interface provides a link `Remove language` to delete the current language shown at "Select language". If a user accidentally removes a translation they can recover it by re-adding it to the form.

  This feature is visible during the creation and edition of translatable resources.

  ![Translations interface enabled](../../img/translations/interface_translations/translations-interface-enabled-en.png)

* When the translation interface is disabled:
  When this feature is disabled users will see standard forms without the translation interface and without highlighted translation fields.

  ![Translations interface disabled](../../img/translations/interface_translations/translations-interface-disabled-en.png)
