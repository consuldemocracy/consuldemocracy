module Polymorphic

  private

    def resource
      if resource_model.to_s == 'Budget::Investment'
        @resource ||= instance_variable_get("@investment")
      else
        @resource ||= instance_variable_get("@#{resource_name}")
      end
    end

    def resource_name
      @resource_name ||= resource_model.to_s.downcase
    end

    def resource_relation
      @resource_relation ||= resource_model.all
    end

    def set_resource_instance
      instance_variable_set("@#{resource_name}", @resource)
    end

    def set_resources_instance
      instance_variable_set("@#{resource_name.pluralize}", @resources)
    end

    def strong_params
      send("#{resource_name}_params")
    end

end
