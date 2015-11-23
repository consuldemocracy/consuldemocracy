class AddExternalLinkToDebates < ActiveRecord::Migration
  def change
    add_column :debates, :external_link, :string
  end
end
