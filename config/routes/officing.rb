### Modified in: Routes in config/routes/custom.rb

### ToDo: Figure out a way to maintain Consul's routes in this file,
#         whilst modifying them in routes/custom.rb
#         The main problem is that routes can not be duplicated
###

# namespace :officing do
#   resources :polls, only: [:index] do
#     get :final, on: :collection
#     resources :results, only: [:new, :create, :index]
#   end

#   resource :residence, controller: "residence", only: [:new, :create]
#   resources :voters, only: [:new, :create]
#   root to: "dashboard#index"
# end
