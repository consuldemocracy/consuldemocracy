class AddLegislationIdToAnnotations < ActiveRecord::Migration[4.2]
  def change
    remove_reference :annotations, :proposal
    add_reference :annotations, :legislation, index: true, foreign_key: true
  end
end
