class CreateModerators < ActiveRecord::Migration
  def change
    create_table :moderators do |t|
      t.belongs_to :user, index: true, foreign_key: true
    end
  end
end
