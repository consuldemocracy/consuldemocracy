class SetExternalLinkMaxLength < ActiveRecord::Migration
  def change
  	change_column :debates, :external_link, :string, limit: 100
  end
end
