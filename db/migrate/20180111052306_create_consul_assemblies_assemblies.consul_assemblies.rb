# This migration comes from consul_assemblies (originally 20180110173615)
class CreateConsulAssembliesAssemblies < ActiveRecord::Migration
  def change
    create_table :consul_assemblies_assemblies do |t|

      t.string 'name', null: false
      t.string 'general_description'
      t.string 'scope_description'
      t.integer 'geozone_id', null: false, index: true
      t.string 'about_venue'

      t.timestamps null: false
    end
  end
end
