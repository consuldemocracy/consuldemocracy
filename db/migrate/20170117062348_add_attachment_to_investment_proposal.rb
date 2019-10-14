class AddAttachmentToInvestmentProposal < ActiveRecord::Migration
  def change
    add_column :budget_investments, :attachment, :string
    add_column :budget_investments, :attachment_verified, :boolean
    add_column :budget_investments, :attachment_verified_by, :string
  end
end
