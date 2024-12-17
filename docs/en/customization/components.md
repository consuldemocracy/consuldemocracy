# Customizing components

For components, customization can be used to change both the logic (included in a `.rb` file) and the view (included in a `.erb` file). If you only want to customize the logic for, let's say, the `Admin::TableActionsComponent`, create a file named `app/components/custom/admin/table_actions_component.rb` with the following content:

```ruby
load Rails.root.join("app", "components", "admin", "table_actions_component.rb")

class Admin::TableActionsComponent
  # Your custom logic here
end
```

Check the [models customization](models.md) section for more information about customizing Ruby classes.

If, on the other hand, you also want to customize the view, you need a small modification. Instead of the previous code, use:

```ruby
class Admin::TableActionsComponent < ApplicationComponent; end

load Rails.root.join("app", "components", "admin", "table_actions_component.rb")

class Admin::TableActionsComponent
  # Your custom logic here
end
```

This will make the component use the view in `app/components/custom/admin/table_actions_component.html.erb`. You can create this file and customize it to your needs, the same way you can [customize views](views.md).
