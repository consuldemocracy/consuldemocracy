# Solo permitmos el sign-in, el resto de las rutas realmente nos las eliminamos
devise_for :users, controllers: {
                     registrations: "users/registrations",
                     sessions: "users/sessions",
                   }, skip:[:registrations,:passwords,:confirmations]

# vamos a crear una ruta de "compatibilidad" con el codigo original, asociada al sign-up
# y que va a permitir el registro, realmente nos redirige al sign-in, el cual tiene
# vinculada una precondición para dirigir a la página inicial del portal.
devise_scope :user do
  get "users/sign_up", to: "users/sessions#new",as: :new_user_registration
  get "users/participacion", to: "users/sessions#participacion", as: :participacion_logon
  get "users/me", to: "users/sessions#me", as: :participacion_me
  put :user_registration, to: 'users/registrations#update'
  patch :user_registration, to: 'users/registrations#update'
  get 'users/edit' => 'users/registrations#edit', :as => 'edit_user_registration'
end



#devise_scope :user do
#  patch "/user/confirmation", to: "users/confirmations#update", as: :update_user_confirmation
#  get "/user/registrations/check_username", to: "users/registrations#check_username"
#  get "users/sign_up/success", to: "users/registrations#success"
#  get "users/registrations/delete_form", to: "users/registrations#delete_form"
#  delete "users/registrations", to: "users/registrations#delete"
#  get :finish_signup, to: "users/registrations#finish_signup"
#  patch :do_finish_signup, to: "users/registrations#do_finish_signup"
#end



#
# No soportamos el registro de asociaciones
#
#devise_for :organizations, class_name: "User",
#           controllers: {
#             registrations: "organizations/registrations",
#             sessions: "devise/sessions"
#           },
#           skip: [:omniauth_callbacks]

#devise_scope :organization do
#  get "organizations/sign_up/success", to: "organizations/registrations#success"
#end
