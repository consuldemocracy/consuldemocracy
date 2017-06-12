class AddAttachmentImageToBudgetInvestments < ActiveRecord::Migration
  def self.up
    change_table :budget_investments do |t|
      t.attachment :image
    end
  end

  def self.down
    remove_attachment :budget_investments, :image
  end
end
