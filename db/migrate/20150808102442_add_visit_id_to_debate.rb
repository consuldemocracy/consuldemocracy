class AddVisitIdToDebate < ActiveRecord::Migration[4.2]
  def change
    add_column :debates, :visit_id, :string
  end
end
