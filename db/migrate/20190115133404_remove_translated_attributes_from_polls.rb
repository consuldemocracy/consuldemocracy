class RemoveTranslatedAttributesFromPolls < ActiveRecord::Migration
  def change
    remove_columns :polls, :name, :summary, :description
  end
end
