class AddGeozoneToHeadings < ActiveRecord::Migration[5.0]
  def change
    add_reference :budget_headings, :geozone, index: true, foreign_key: true
  end
end
