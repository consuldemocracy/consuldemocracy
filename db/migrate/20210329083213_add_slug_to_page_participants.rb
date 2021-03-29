class AddSlugToPageParticipants < ActiveRecord::Migration[5.2]
  def change
    add_column :page_participants, :slug, :string
  end
end
