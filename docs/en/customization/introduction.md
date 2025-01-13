# Customization

You can modify your own Consul Democracy to adapt it to the visual style of your institution. To do so, first you'll have to [create your own fork](../getting_started/create.md).

The main principle to follow when customizing Consul Democracy is doing so in a way that custom changes are isolated so, when updating to a new version of Consul Democracy, it'll be easier to check which code belongs to the application and how the code changed in the new version. Otherwise, it'll be very hard to adapt your custom changes to the new version.

For that purpose, Consul Democracy includes custom folders so you rarely have to touch the original application files.

## Special Folders and Files

In order to customize your Consul Democracy fork, you'll make use of some `custom` folders on the following paths:

* `app/assets/images/custom/`
* `app/assets/javascripts/custom/`
* `app/assets/stylesheets/custom/`
* `app/components/custom/`
* `app/controllers/custom/`
* `app/form_builders/custom/`
* `app/graphql/custom/`
* `app/lib/custom/`
* `app/mailers/custom/`
* `app/models/custom/`
* `app/models/custom/concerns/`
* `app/views/custom/`
* `config/locales/custom/`
* `spec/components/custom/`
* `spec/controllers/custom/`
* `spec/models/custom/`
* `spec/routing/custom/`
* `spec/system/custom/`

There are also files where you can apply some customizations:

* `app/assets/javascripts/custom.js`
* `app/assets/stylesheets/custom.css`
* `app/assets/stylesheets/_custom_settings.css`
* `app/assets/stylesheets/_consul_custom_overrides.css`
* `config/application_custom.rb`
* `config/environments/custom/development.rb`
* `config/environments/custom/preproduction.rb`
* `config/environments/custom/production.rb`
* `config/environments/custom/staging.rb`
* `config/environments/custom/test.rb`
* `config/routes/custom.rb`
* `Gemfile_custom`

Using these files, you will be able to customize [translations](translations.md), [images](images.md), [CSS](css.md), [JavaScript](javascript.md), [HTML views](views.md), any Ruby code like [models](models.md), [controllers](controllers.md), [components](components.md) or [other Ruby classes](ruby.md), [gems](gems.md), [application configuration](application.md), [routes](routes.md) and [tests](tests.md).

## Running the tests

When customizing the code, it is **very important** that all the tests in your test suite are still passing. If not, there will be issues when upgrading to a new version of Consul Democracy (or even when updating the custom changes) that won't be detected until the code is running on production. Consul Democracy includes more than 6000 tests checking the way the application behaves; without them, it'd be impossible to make sure that new code doesn't break any existing behavior.

So, first, make sure you've [configured your fork](../getting_started/configuration.md) so it uses a continuous integration system that runs all the tests whenever you make changes to the code. When changing the code, we recommend opening pull requests (a.k.a. merge requests) using a development branch so the tests run before the custom changes are added to the `master` branch.

Then, if some tests fail, check one of the tests and see whether the test fails because the custom code contains a bug or because the test checks a behavior that no longer applies due to your custom changes (for example, you might modify the code so only verified users can add comments, but there might be a test checking that any user can add comments, which is the default behavior). If the test fails due to a bug in the custom code, fix it ;). If it fails due to a behavior that no longer applies, check the [tests customization](tests.md) section.

We also **strongly recommend adding tests for your custom changes**, so you'll have a way to know whether these changes keep working when upgrading to a new version of Consul Democracy.

## Coding conventions

Consul Democracy includes linters that define code conventions for Ruby, ERB, JavaScript, SCSS and Markdown. We recommend you follow these conventions in your code as well in order to make it easier to maintain. See also the [coding conventions](../open_source/coding_conventions.md) section for more information.
