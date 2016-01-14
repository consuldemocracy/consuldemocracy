class AddAlignmentToComments < ActiveRecord::Migration
  def change
    change_table :comments do |t|
      t.integer :alignment, limit: 1
    end
  end
end
