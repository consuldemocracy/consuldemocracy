class DeviseCustomFailureApp < Devise::FailureApp
  protected

    def scope_url
      opts  = {}

      # Initialize script_name with nil to prevent infinite loops in
      # authenticated mounted engines in rails 4.2 and 5.0
      opts[:script_name] = nil

      # Custom route
      route = :new_user_session_url

      opts[:format] = request_format unless skip_format?

      router_name = Devise.mappings[scope].router_name || Devise.available_router_name
      context = send(router_name)

      if relative_url_root?
        opts[:script_name] = relative_url_root

      # We need to add the rootpath to `script_name` manually for applications that use a Rails
      # version lower than 5.1. Otherwise, it is going to generate a wrong path for Engines
      # that use Devise. Remove it when the support of Rails 5.0 is droped.
      elsif root_path_defined?(context) && !rails_51_and_up?
        rootpath = context.routes.url_helpers.root_path

        # Fix redirect path
        rootpath = "/" if rootpath == Rails.application.config.root_directory

        opts[:script_name] = rootpath.chomp('/') if rootpath.length > 1
      end

      if context.respond_to?(route)
        context.send(route, opts)
      elsif respond_to?(:root_url)
        root_url(opts)
      else
        "/"
      end
    end
end
