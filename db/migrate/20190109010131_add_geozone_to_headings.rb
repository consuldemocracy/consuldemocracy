class AddGeozoneToHeadings < ActiveRecord::Migration[5.0]
  unless column_exists? :budget_headings, :geozone_id
    def change
      add_reference :budget_headings, :geozone, index: true, foreign_key: true
    end
  end
end
