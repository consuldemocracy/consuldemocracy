# Customization

You can modify your own CONSUL to have your custom visual style, but first you'll have to [create your own fork from](forks/create.md).

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

## Translation interface

The aim of this functionality is to allow the introduction of all the dynamic contents of the application (proposals, debates, budgetary investments and comments) in different languages. From the administration panel you can activate or deactivate the translation interface.

#### Enable module
To activate the functionality you must follow 2 steps:
1. Execute the following command `bin/rake settings:create_translation_interface_setting RAILS_ENV=production`
1. Accessing through the administration panel of your application to the section **Configuration > Funcionalidades** and activate the module **Translation Interface** as you can see below:
![Active interface translations](../../img/translations/interface_translations/active-interface-translations-en.png)

#### Use Cases

* When the translation interface is active:
As we can see in the image appears a selector to add languages where each time we select one appears in the selector of languages in use and the translatable fields appears with a blue background.  Also we have a button `Remove language` to delete a language in case of needing it.
This feature is visible both for the creation pages and for the editing pages.
![Translations inteface enabled](../../img/translations/interface_translations/translations-interface-enabled-en.png)

* When the translation interface is disabled:
As you can see in the image when this feature is deactivated, the current rendering is maintained in both the creation and edition forms:
![Translations inteface enabled](../../img/translations/interface_translations/translations-interface-disabled-en.png)
