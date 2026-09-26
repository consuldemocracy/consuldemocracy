module Polymorphic
  private

    def resource
      if resource_model.to_s == "Budget::Investment"
        @resource ||= instance_variable_get(:@investment)
      elsif resource_model.to_s == "Legislation::Proposal"
        @resource ||= instance_variable_get(:@proposal)
      else
        @resource ||= instance_variable_get("@#{resource_name}")
      end
    end

    def resource_name
      @resource_name ||= resource_model.to_s.downcase
    end
end
