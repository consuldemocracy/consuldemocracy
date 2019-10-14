class AddPublishedAt < ActiveRecord::Migration
  def change
    add_column :consul_assemblies_meetings, :published_at, :datetime
  end
end
