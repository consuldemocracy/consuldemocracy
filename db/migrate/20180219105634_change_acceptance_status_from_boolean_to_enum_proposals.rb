class ChangeAcceptanceStatusFromBooleanToEnumProposals < ActiveRecord::Migration
  def change
     add_column :consul_assemblies_proposals, :acceptance_status, :string, default: 'undecided'
  end
end
