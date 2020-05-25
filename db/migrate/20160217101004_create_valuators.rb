class CreateValuators < ActiveRecord::Migration[4.2]
  def change
    create_table :valuators do |t|
      t.belongs_to :user, index: true, foreign_key: true
    end
  end
end
