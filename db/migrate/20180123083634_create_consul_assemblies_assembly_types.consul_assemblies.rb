# This migration comes from consul_assemblies (originally 20180123082620)
class CreateConsulAssembliesAssemblyTypes < ActiveRecord::Migration
  def change
    create_table :consul_assemblies_assembly_types do |t|
      t.string 'name', null: false
      t.string 'description'
      t.timestamps null: false
    end
  end
end
