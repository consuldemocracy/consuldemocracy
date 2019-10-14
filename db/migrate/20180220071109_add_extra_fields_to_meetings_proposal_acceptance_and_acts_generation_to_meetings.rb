class AddExtraFieldsToMeetingsProposalAcceptanceAndActsGenerationToMeetings < ActiveRecord::Migration
  def change
    add_column :consul_assemblies_meetings, :accepts_proposals, :boolean, default: true, null: false
    add_column :consul_assemblies_meetings, :will_generate_acts, :boolean, default: true, null: false
  end
end
