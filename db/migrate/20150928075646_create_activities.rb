class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.string :action
      t.belongs_to :trackable, polymorphic: true
    end
  end
end
