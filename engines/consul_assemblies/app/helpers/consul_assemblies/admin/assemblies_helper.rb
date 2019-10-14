module ConsulAssemblies
  module Admin::AssembliesHelper

    def geozones_select_options(geozones)
      geozones.map do |geozone|
        [geozone.name, geozone.id]
      end
    end

    def assembly_types_select_options(assembly_types)
      assembly_types.map do |assembly_type|
        [assembly_type.name, assembly_type.id]
      end
    end

  end
end
