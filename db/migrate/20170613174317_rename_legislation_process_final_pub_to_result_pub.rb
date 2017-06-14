class RenameLegislationProcessFinalPubToResultPub < ActiveRecord::Migration
  def change
    rename_column :legislation_processes, :final_publication_date, :result_publication_date
  end
end
