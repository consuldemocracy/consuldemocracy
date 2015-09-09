class SetTagNameLimit < ActiveRecord::Migration
  def change
    change_column :tags, :name, :string, limit: 40
  end
end
