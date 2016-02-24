class CreateValuationAssignments < ActiveRecord::Migration
  def change
    create_table :valuation_assignments do |t|
      t.belongs_to :valuator
      t.belongs_to :spending_proposal
      t.timestamps null: false
    end
  end
end
