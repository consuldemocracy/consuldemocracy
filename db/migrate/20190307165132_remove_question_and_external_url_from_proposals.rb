class RemoveQuestionAndExternalUrlFromProposals < ActiveRecord::Migration
  def change
    remove_column :proposals, :question, :string
    remove_column :proposals, :external_url, :string
  end
end
