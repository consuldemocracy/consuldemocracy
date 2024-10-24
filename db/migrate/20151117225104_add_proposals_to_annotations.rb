class AddProposalsToAnnotations < ActiveRecord::Migration[4.2]
  def change
    add_reference :annotations, :proposal, index: true, foreign_key: true
  end
end
