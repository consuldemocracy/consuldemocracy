class AddValidAnswersToEnquiry < ActiveRecord::Migration
  def change
    add_column :enquiries, :valid_answers, :string
  end
end
