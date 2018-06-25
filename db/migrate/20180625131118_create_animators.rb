class CreateAnimators < ActiveRecord::Migration
  def change
    create_table :animators do |t|
      t.belongs_to :user, index: true, foreign_key: true
    end
  end
end