require_dependency "#{Rails.root}/app/controllers/admin/legislation/processes_controller"

Admin::Legislation::ProcessesController.class_eval do
  private
    alias_method :consul_allowed_params, :allowed_params

    def allowed_params
      consul_allowed_params + [:film_library]
    end
end
