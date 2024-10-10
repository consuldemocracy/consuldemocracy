# Customizing controllers

Just like models, controllers are written using Ruby code, so their customization is similar, only we'll use the `app/controllers/custom/` folder instead of the `app/models/custom/` folder. Check the [models customization](models.md) section for more information.

## Customizing allowed parameters

When customizing Consul Democracy, sometimes you might want to add a new field to a form. Other than [customizing the view](views.md) or [the component](components.md) that renders that form, you need to modify the controller so the new field is accepted. If not, the new field will silently be ignored; this is done to prevent [mass assignment attacks](https://en.wikipedia.org/wiki/Mass_assignment_vulnerability).

For example, let's say you've modified the `SiteCustomization::Page` model so it uses a field called `author_nickname` and you've added that field to the form to create a custom page in the admin area. To add the allowed parameter to the controller, create a file `app/controllers/custom/admin/site_customization/pages_controller.rb` with the following content:

```ruby
load Rails.root.join("app", "controllers", "admin", "site_customization", "pages_controller.rb")

class Admin::SiteCustomization::PagesController

  private

    alias_method :consul_allowed_params, :allowed_params

    def allowed_params
      consul_allowed_params + [:author_nickname]
    end
end
```

Note we're aliasing and then calling the original `allowed_params` method, so all the parameters allowed in the original code will also be allowed in our custom method.
