class RemoveVisitIdFromDebates < ActiveRecord::Migration[7.0]
  def change
    remove_column :debates, :visit_id, :string
  end
end
