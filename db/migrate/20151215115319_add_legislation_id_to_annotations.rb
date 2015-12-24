class AddLegislationIdToAnnotations < ActiveRecord::Migration
  def change
    remove_reference :annotations, :proposal
    add_reference :annotations, :legislation, index: true, foreign_key: true
  end
end
