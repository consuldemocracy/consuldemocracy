class AddAssemblyTypeIdToAssemblies < ActiveRecord::Migration
  def change
    add_column :consul_assemblies_assemblies, :assembly_type_id, :integer, index: true
  end
end
