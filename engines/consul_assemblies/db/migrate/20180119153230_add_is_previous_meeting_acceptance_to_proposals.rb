class AddIsPreviousMeetingAcceptanceToProposals < ActiveRecord::Migration
  def change
    add_column :consul_assemblies_proposals, :is_previous_meeting_acceptance, :boolean
  end
end
