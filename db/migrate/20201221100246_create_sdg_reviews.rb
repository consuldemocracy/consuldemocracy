class CreateSDGReviews < ActiveRecord::Migration[5.2]
  def change
    create_table :sdg_reviews do |t|
      t.references :relatable, polymorphic: true, index: { unique: true }
      t.timestamps
    end
  end
end
