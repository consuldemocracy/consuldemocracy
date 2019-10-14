module ConsulAssemblies
  module Admin::MeetingsHelper

    def assemblies_statuses_select_options
      ConsulAssemblies::Meeting::VALID_STATUSES.map do |status|
        [t('.'+status), status]
      end
    end
    def assemblies_select_options(assemblies)
      assemblies.map do |assembly|
        [assembly.name, assembly.id]
      end
    end

  end
end
