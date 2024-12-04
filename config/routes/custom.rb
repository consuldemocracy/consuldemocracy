# Add your custom routes here.
#
# For example, if you'd like to add a new section in the admin area
# to manage happy thoughts and verify they've become true, you can
# write:
#
# namespace :admin do
#   resources :happy_thoughts do
#     member do
#       put :verify
#     end
#   end
# end
#
# Or, if, for example, you'd like to add a form to edit debates in the
# admin area:
#
# namespace :admin do
#   resources :debates, only: [:edit, :update]
# end
#
# Doing so, the existing debates routes in the admin area will be kept,
# and the routes to edit and update them will be added.
#
# Note that the routes you define on this file will take precedence
# over the default routes. So, if you define a route for `/proposals`,
# the default action for `/proposals` will not be used and the one you
# define will be used instead.

constraints lambda { |request| !Rails.application.multitenancy_management_mode? } do
  # The routes defined within this block will not be accessible if multitenancy
  # management mode is enabled. If you need these routes to be accessible when
  # using multitenancy management mode, you should define them outside of this block.
  #
  # If multitenancy management mode is not being used, routes can be included within
  # this block and will still be accessible.
end
