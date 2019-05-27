class ActivateNewsletterByDefault < ActiveRecord::Migration[4.2]
  def change
    change_column :users, :newsletter, :boolean, default: true
  end
end
