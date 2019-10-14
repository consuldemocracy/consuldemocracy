# This migration comes from consul_assemblies (originally 20180119153230)
class AddIsPreviousMeetingAcceptanceToProposals < ActiveRecord::Migration
  def change
    add_column :consul_assemblies_proposals, :is_previous_meeting_acceptance, :boolean
  end
end
