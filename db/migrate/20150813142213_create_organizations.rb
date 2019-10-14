class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.string :name, limit: 80
      t.datetime :verified_at
      t.datetime :rejected_at
    end
  end
end
