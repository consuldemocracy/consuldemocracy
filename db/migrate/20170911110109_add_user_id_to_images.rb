class AddUserIdToImages < ActiveRecord::Migration
  def change
    add_reference :images, :user, index: true, foreign_key: true
  end
end
