class CreateLegislationProposals < ActiveRecord::Migration
  def change
    create_table :legislation_proposals do |t|
      t.references :legislation_process, index: true, foreign_key: true
      t.string     :title, limit: 80
      t.text       :description
      t.string     :question
      t.string     :external_url
      t.integer    :author_id
      t.datetime   :hidden_at
      t.integer    :flags_count, default: 0
      t.datetime   :ignored_flag_at
      t.integer    :cached_votes_up, default: 0
      t.integer    :comments_count, default: 0
      t.datetime   :confirmed_hide_at
      t.integer    :hot_score, limit: 8, default: 0
      t.integer    :confidence_score, default: 0
      t.string     :responsible_name, limit: 60
      t.text       :summary
      t.string     :video_url
      t.tsvector   :tsv
      t.integer    :geozone_id
      t.datetime   :retired_at
      t.string     :retired_reason
      t.text       :retired_explanation
      t.integer    :community_id

      t.datetime   :created_at, null: false
      t.datetime   :updated_at, null: false
    end
  end
end
