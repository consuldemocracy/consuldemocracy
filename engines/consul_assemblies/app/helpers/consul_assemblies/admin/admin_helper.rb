module ConsulAssemblies
  module Admin::AdminHelper
    def namespace
      'consul_assemblies/admin'
    end

    def boolean_check(boolean_value)
      (boolean_value ? '&#x2714;' : '&#x2718;').html_safe
    end

    def proposal_origin_options
      ConsulAssemblies::Proposal::PROPOSAL_ORIGIN.collect { |origin| [proposal_origin_name(origin), origin] }
    end

    def proposal_acceptance_status_options
      ConsulAssemblies::Proposal::PROPOSAL_ACCEPTANCE_STATUSES.collect { |origin| [proposal_acceptance_status_name(origin), origin] }
    end

    def proposal_acceptance_status_name(status)
      I18n.t("proposal_acceptance_status.#{status}")
    end

    def proposal_origin_name(status)
      I18n.t("proposal_origin.#{status}")
    end

    def method_missing method, *args, &block

      puts "METHODS LOOING #{method}"
      if method.to_s.end_with?('_path') or method.to_s.end_with?('_url')
        if main_app.respond_to?(method)
          main_app.send(method, *args)
        else
          super
        end
      else
        super
      end
    end

    def respond_to?(method)
      if method.to_s.end_with?('_path') or method.to_s.end_with?('_url')
        if main_app.respond_to?(method)
          true
        else
          super
        end
      else
        super
      end
    end
  end
end
