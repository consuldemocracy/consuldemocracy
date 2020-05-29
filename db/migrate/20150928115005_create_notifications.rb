class CreateNotifications < ActiveRecord::Migration[4.2]
  def change
    create_table :notifications do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.belongs_to :activity, index: true, foreign_key: true
      t.boolean :read, default: false
    end
  end
end
