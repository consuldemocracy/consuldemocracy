class ActivateNewsletterByDefault < ActiveRecord::Migration
  def change
    change_column :users, :newsletter, :boolean, default: true
  end
end
