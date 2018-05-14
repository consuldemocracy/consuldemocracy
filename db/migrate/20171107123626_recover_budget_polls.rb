class RecoverBudgetPolls < ActiveRecord::Migration
  def change
    create_table :budget_polls do |t|
      t.string :name
      t.string :email
      t.string :preferred_subject
      t.boolean :collective
      t.boolean :public_worker
      t.boolean :proposal_author
      t.boolean :selected_proposal_author
    end
  end
end
