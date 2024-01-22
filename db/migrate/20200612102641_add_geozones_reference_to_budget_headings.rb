class AddGeozonesReferenceToBudgetHeadings < ActiveRecord::Migration[5.0]
  def change
    unless column_exists? :budget_headings, :geozone_id
      add_reference :budget_headings, :geozone, index: true, foreign_key: true
    end
  end
end
