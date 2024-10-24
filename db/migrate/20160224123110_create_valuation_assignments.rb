class CreateValuationAssignments < ActiveRecord::Migration[4.2]
  def change
    create_table :valuation_assignments do |t|
      t.belongs_to :valuator
      t.belongs_to :spending_proposal
      t.timestamps null: false
    end
  end
end
