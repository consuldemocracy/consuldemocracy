class RemoveQuestionAndExternalUrlFromProposals < ActiveRecord::Migration[4.2]
  def change
    remove_column :proposals, :question, :string
    remove_column :proposals, :external_url, :string
  end
end
