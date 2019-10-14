class CreateConsulAssembliesAssemblyTypes < ActiveRecord::Migration
  def change
    create_table :consul_assemblies_assembly_types do |t|
      t.string 'name', null: false
      t.string 'description'
      t.timestamps null: false
    end
  end
end
