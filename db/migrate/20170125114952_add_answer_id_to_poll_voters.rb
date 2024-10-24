class AddAnswerIdToPollVoters < ActiveRecord::Migration[4.2]
  def change
    add_column :poll_voters, :answer_id, :integer, default: nil

    add_index :poll_voters, :document_number
    add_index :poll_voters, :poll_id
    add_index :poll_voters, [:poll_id, :document_number, :document_type], name: "doc_by_poll"
  end
end
