class RemoveDefaultValueInUserPublicActivity < ActiveRecord::Migration[7.1]
  def change
    change_table :users do |t|
      t.change_default :public_activity, from: true, to: nil
    end
  end
end
