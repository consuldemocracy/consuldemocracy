class RemoveNullStatusToPrevousAcceptanceFlag < ActiveRecord::Migration
  def change
    change_column_default(:consul_assemblies_proposals, :is_previous_meeting_acceptance, false)
  end
end
