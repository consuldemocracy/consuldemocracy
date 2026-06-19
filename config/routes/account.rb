resource :account, controller: "account", only: [:show, :update]

resource :subscriptions, only: [:edit, :update]
