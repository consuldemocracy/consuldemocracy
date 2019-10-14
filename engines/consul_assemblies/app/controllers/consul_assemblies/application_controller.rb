module ConsulAssemblies
  class ApplicationController < ::ApplicationController
    protect_from_forgery with: :exception

    include Rails.application.routes.mounted_helpers
  end
end
