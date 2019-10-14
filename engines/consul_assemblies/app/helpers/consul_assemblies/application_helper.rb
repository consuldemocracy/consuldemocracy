module ConsulAssemblies
  module ApplicationHelper

    def assemblies_select_options(assemblies)
      assemblies.map do |assembly|
        [assembly.name, assembly.id]
      end
    end
  end
end
