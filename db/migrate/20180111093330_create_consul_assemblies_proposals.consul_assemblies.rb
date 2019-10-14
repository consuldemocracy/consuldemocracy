class CreateConsulAssembliesProposals < ActiveRecord::Migration
  def change
    create_table :consul_assemblies_proposals do |t|

      t.integer 'meeting_id', null: false, index: true
      t.string 'title', null: false
      t.text 'description'
      t.integer 'user_id'
      t.boolean 'accepted'
      t.boolean 'terms_of_service'


      t.timestamps null: false
    end
  end
end
