# This migration comes from consul_assemblies (originally 20180117153244)
class AddAttachmentToMeetings < ActiveRecord::Migration
  def change
    add_column :consul_assemblies_meetings, :attachment, :string
    add_column :consul_assemblies_meetings, :attachment_url, :string
  end
end
