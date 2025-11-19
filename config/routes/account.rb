resource :account, controller: "account", only: [:show, :update, :delete]

resource :subscriptions, only: [:edit, :update]
