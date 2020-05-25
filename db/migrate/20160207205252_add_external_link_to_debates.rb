class AddExternalLinkToDebates < ActiveRecord::Migration[4.2]
  def change
    add_column :debates, :external_link, :string, limit: 100
  end
end
