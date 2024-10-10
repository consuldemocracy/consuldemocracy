# Customizing routes

When adding custom controller actions, you also need to define a route to configure the URL that will be used for those actions. You can do so by editing the `config/routes/custom.rb` file.

For example, if you'd like to add a new section in the admin area to manage happy thoughts and verify they've become true, you can write:

```ruby
namespace :admin do
  resources :happy_thoughts do
    member do
      put :verify
    end
  end
end
```

Or, if, for example, you'd like to add a form to edit debates in the admin area:

```ruby
namespace :admin do
  resources :debates, only: [:edit, :update]
end
```

Doing so, the existing debates routes in the admin area will be kept, and the routes to edit and update them will be added.

Note that the routes you define on this file will take precedence over the default routes. So, if you define a route for `/proposals`, the default action for `/proposals` will not be used and the one you define will be used instead.
