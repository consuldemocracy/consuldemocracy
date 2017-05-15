class AddProblemToProposals < ActiveRecord::Migration
  def change
    add_reference :proposals, :problem, index: true, foreign_key: true
  end
end
