class AddAttendantsTextToMeeting < ActiveRecord::Migration
  def change
    add_column :consul_assemblies_meetings, :attendants_text, :string, default: '', null: false
  end
end
