class CreateAdministrators < ActiveRecord::Migration
  def change
    create_table :administrators do |t|
      t.belongs_to :user, index: true, foreign_key: true
    end
  end
end
