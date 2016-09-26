class CreateEnquiryAnswers < ActiveRecord::Migration
  def change
    create_table :enquiry_answers do |t|
      t.integer :author_id, index: true
      t.integer :enquiry_id, index: true, foreign_key: true
      t.string :answer, index: true
    end

    add_foreign_key :enquiry_answers, :users, column: :author_id
    add_index :enquiry_answers, [:author_id, :enquiry_id], unique: true
  end
end
