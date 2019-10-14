class CreateConsulAssembliesMeetings < ActiveRecord::Migration
  def change
    create_table :consul_assemblies_meetings do |t|

      t.string 'title', null: false
      t.string 'description'
      t.string 'summary'
      t.string 'status', null: false
      t.string 'about_venue'
      t.integer 'assembly_id', null: false, index: true

      t.integer 'followers_count', default: 0
      t.integer 'comments_count', default: 0

      t.datetime 'close_accepting_proposals_at'
      t.datetime 'scheduled_at'

      t.timestamps null: false
    end
  end
end
