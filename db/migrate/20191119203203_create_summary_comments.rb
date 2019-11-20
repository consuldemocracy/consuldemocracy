class CreateSummaryComments < ActiveRecord::Migration[5.0]
  def change
    create_table :summary_comments do |t|
      t.integer :commentable_id
      t.string :commentable_type
      t.text :body
      t.references :proposal, foreign_key: true

      t.timestamps
    end
  end
end
