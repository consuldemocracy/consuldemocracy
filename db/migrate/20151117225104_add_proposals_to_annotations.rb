class AddProposalsToAnnotations < ActiveRecord::Migration
  def change
    add_reference :annotations, :proposal, index: true, foreign_key: true
  end
end
