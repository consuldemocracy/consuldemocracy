scope module: :verification do
  resource :residenceva, controller: "residenceva", only: [:new, :create]
  # resource :residence, controller: "residence", only: [:new, :create]
  resource :sms, controller: "sms", only: [:new, :create, :edit, :update]
  resource :verified_user, controller: "verified_user", only: [:show]
  resource :email, controller: "email", only: [:new, :show, :create]
  resource :letter, controller: "letter", only: [:new, :create, :show, :edit, :update]
end

# resource :verification, controller: "verificationva_controller", only [:show]
# resource :verification, controller: "verification", only: [:show]
