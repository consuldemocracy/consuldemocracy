class AddResponsibleNameToOrganizations < ActiveRecord::Migration
  def up
    add_column :organizations, :responsible_name, :string, limit: 60

    Organization.find_each do |org|
      org.update(responsible_name: org.name) if org.responsible_name.blank?
    end
  end

  def down
    remove_column :organizations, :responsible_name
  end
end
