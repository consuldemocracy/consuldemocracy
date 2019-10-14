class EnableConsulAssemblies < ActiveRecord::Migration
  def up
    Setting['feature.assemblies'] = true

    Geozone.order('name').each do |geozone|
      ConsulAssemblies::Assembly.create(geozone: geozone, name: "Asamblea de #{geozone.name}")
    end
  end

  def down
    Setting['feature.assemblies'] = false
    ConsulAssemblies::Assembly.delete_all
  end
end
