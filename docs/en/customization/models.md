# Customizing models

In order to create new models or customize existing ones, you can use the `app/models/custom/` folder.

If you're adding a new model that doesn't exist in the original Consul Democracy, simply add it to that folder.

If, on the other hand, you are changing a model that exists in the application, create a file in `app/models/custom/` with same name as the file you're changing. For example, if you're changing the `app/models/budget/investment.rb` file, create a file named `app/models/custom/budget/investment.rb` and require the original one:

```ruby
load Rails.root.join("app", "models", "budget", "investment.rb")

class Budget
  class Investment
  end
end
```

Since the custom file requires the original one, at this point, the custom model will behave exactly as the original.

Note that, if we do not require the original file, that file won't be loaded and the custom model will do nothing, which will likely result in errors.

## Adding new methods

In order to add a new method, simply add the new code to the model. For example, let's add a scope that returns the investments created last month:

```ruby
load Rails.root.join("app", "models", "budget", "investment.rb")

class Budget
  class Investment
    scope :last_month, -> { where(created_at: 1.month.ago..) }
  end
end
```

With this code, the custom model will have all the methods of the original model (because it loads the original file) plus the `last_month` scope.

## Modifying existing methods

When modifying existing methods, it is strongly recommended that, when possible, **your custom code calls the original code** and only modifies the cases where it should behave differently. This way, when upgrading to a new version of Consul Democracy that updates the original methods, your custom methods will automatically include the modifications in the original code as well. Sometimes this won't be possible, though, which means you might need to change your custom method when upgrading.

For example, to change the common abilities model so only verified users can create comments, we'll create a file `app/models/custom/abilities/common.rb` with the following content:

```ruby
load Rails.root.join("app", "models", "abilities", "common.rb")

module Abilities
  class Common
    alias_method :consul_initialize, :initialize # create a copy of the original method

    def initialize(user)
      consul_initialize(user) # call the original method
      cannot :create, Comment # undo the permission added in the original method

      if user.level_two_or_three_verified?
        can :create, Comment
      end
    end
  end
end
```

You can find another example in the `app/models/custom/setting.rb` file.
