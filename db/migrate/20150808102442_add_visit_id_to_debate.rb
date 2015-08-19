class AddVisitIdToDebate < ActiveRecord::Migration
  def change
    add_column :debates, :visit_id, :string
  end
end
