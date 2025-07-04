# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2024_10_28_165107) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_trgm"
  enable_extension "plpgsql"
  enable_extension "unaccent"

  create_table "active_poll_translations", id: :serial, force: :cascade do |t|
    t.integer "active_poll_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "description"
    t.index ["active_poll_id"], name: "index_active_poll_translations_on_active_poll_id"
    t.index ["locale"], name: "index_active_poll_translations_on_locale"
  end

  create_table "active_polls", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", precision: nil, null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "activities", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "action"
    t.string "actionable_type"
    t.integer "actionable_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["actionable_id", "actionable_type"], name: "index_activities_on_actionable_id_and_actionable_type"
    t.index ["user_id"], name: "index_activities_on_user_id"
  end

  create_table "admin_notification_translations", id: :serial, force: :cascade do |t|
    t.integer "admin_notification_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "title"
    t.text "body"
    t.index ["admin_notification_id"], name: "index_admin_notification_translations_on_admin_notification_id"
    t.index ["locale"], name: "index_admin_notification_translations_on_locale"
  end

  create_table "admin_notifications", id: :serial, force: :cascade do |t|
    t.string "link"
    t.string "segment_recipient"
    t.integer "recipients_count"
    t.date "sent_at"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "administrators", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "description"
    t.index ["user_id"], name: "index_administrators_on_user_id"
  end

  create_table "age_restrictions", force: :cascade do |t|
    t.integer "order"
    t.integer "min_age"
    t.integer "max_age"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "ahoy_events", force: :cascade do |t|
    t.bigint "visit_id"
    t.bigint "user_id"
    t.string "name"
    t.jsonb "properties"
    t.datetime "time", precision: nil
    t.index ["name", "time"], name: "index_ahoy_events_on_name_and_time"
    t.index ["properties"], name: "index_ahoy_events_on_properties_jsonb_path_ops", opclass: :jsonb_path_ops, using: :gin
    t.index ["user_id"], name: "index_ahoy_events_on_user_id"
    t.index ["visit_id"], name: "index_ahoy_events_on_visit_id"
  end

  create_table "ahoy_events_old", id: :uuid, default: nil, force: :cascade do |t|
    t.uuid "visit_id"
    t.integer "user_id"
    t.string "name"
    t.jsonb "properties"
    t.datetime "time", precision: nil
    t.string "ip"
    t.index ["name", "time"], name: "index_ahoy_events_old_on_name_and_time"
    t.index ["time"], name: "index_ahoy_events_old_on_time"
    t.index ["user_id"], name: "index_ahoy_events_old_on_user_id"
    t.index ["visit_id"], name: "index_ahoy_events_old_on_visit_id"
  end

  create_table "ahoy_visits", force: :cascade do |t|
    t.string "visit_token"
    t.string "visitor_token"
    t.bigint "user_id"
    t.string "ip"
    t.text "user_agent"
    t.text "referrer"
    t.string "referring_domain"
    t.text "landing_page"
    t.string "browser"
    t.string "os"
    t.string "device_type"
    t.string "country"
    t.string "region"
    t.string "city"
    t.string "utm_source"
    t.string "utm_medium"
    t.string "utm_term"
    t.string "utm_content"
    t.string "utm_campaign"
    t.datetime "started_at", precision: nil
    t.index ["user_id"], name: "index_ahoy_visits_on_user_id"
    t.index ["visit_token"], name: "index_ahoy_visits_on_visit_token", unique: true
  end

  create_table "audits", id: :serial, force: :cascade do |t|
    t.integer "auditable_id"
    t.string "auditable_type"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.jsonb "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at", precision: nil
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_type", "auditable_id", "version"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "banner_sections", id: :serial, force: :cascade do |t|
    t.integer "banner_id"
    t.integer "web_section_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "banner_translations", id: :serial, force: :cascade do |t|
    t.integer "banner_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "title"
    t.text "description"
    t.datetime "hidden_at", precision: nil
    t.index ["banner_id"], name: "index_banner_translations_on_banner_id"
    t.index ["hidden_at"], name: "index_banner_translations_on_hidden_at"
    t.index ["locale"], name: "index_banner_translations_on_locale"
  end

  create_table "banners", id: :serial, force: :cascade do |t|
    t.string "target_url"
    t.date "post_started_at"
    t.date "post_ended_at"
    t.datetime "hidden_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "background_color"
    t.text "font_color"
    t.index ["hidden_at"], name: "index_banners_on_hidden_at"
  end

  create_table "budget_administrators", id: :serial, force: :cascade do |t|
    t.integer "budget_id"
    t.integer "administrator_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["administrator_id"], name: "index_budget_administrators_on_administrator_id"
    t.index ["budget_id"], name: "index_budget_administrators_on_budget_id"
  end

  create_table "budget_ballot_lines", id: :serial, force: :cascade do |t|
    t.integer "ballot_id"
    t.integer "investment_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "budget_id"
    t.integer "group_id"
    t.integer "heading_id"
    t.integer "line_weight", default: 1
    t.index ["ballot_id", "investment_id"], name: "index_budget_ballot_lines_on_ballot_id_and_investment_id", unique: true
    t.index ["ballot_id"], name: "index_budget_ballot_lines_on_ballot_id"
    t.index ["budget_id"], name: "index_budget_ballot_lines_on_budget_id"
    t.index ["group_id"], name: "index_budget_ballot_lines_on_group_id"
    t.index ["heading_id"], name: "index_budget_ballot_lines_on_heading_id"
    t.index ["investment_id"], name: "index_budget_ballot_lines_on_investment_id"
  end

  create_table "budget_ballots", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "budget_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "ballot_lines_count", default: 0
    t.boolean "physical", default: false
    t.integer "poll_ballot_id"
  end

  create_table "budget_content_blocks", id: :serial, force: :cascade do |t|
    t.integer "heading_id"
    t.text "body"
    t.string "locale"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["heading_id"], name: "index_budget_content_blocks_on_heading_id"
  end

  create_table "budget_group_translations", id: :serial, force: :cascade do |t|
    t.integer "budget_group_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "name"
    t.index ["budget_group_id"], name: "index_budget_group_translations_on_budget_group_id"
    t.index ["locale"], name: "index_budget_group_translations_on_locale"
  end

  create_table "budget_groups", id: :serial, force: :cascade do |t|
    t.integer "budget_id"
    t.string "slug"
    t.integer "max_votable_headings", default: 1
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["budget_id"], name: "index_budget_groups_on_budget_id"
  end

  create_table "budget_heading_translations", id: :serial, force: :cascade do |t|
    t.integer "budget_heading_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "name"
    t.index ["budget_heading_id"], name: "index_budget_heading_translations_on_budget_heading_id"
    t.index ["locale"], name: "index_budget_heading_translations_on_locale"
  end

  create_table "budget_headings", id: :serial, force: :cascade do |t|
    t.integer "group_id"
    t.bigint "price"
    t.integer "population"
    t.string "slug"
    t.boolean "allow_custom_content", default: false
    t.text "latitude"
    t.text "longitude"
    t.integer "geozone_id"
    t.integer "max_ballot_lines", default: 1
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["geozone_id"], name: "index_budget_headings_on_geozone_id"
    t.index ["group_id"], name: "index_budget_headings_on_group_id"
  end

  create_table "budget_investment_translations", id: :serial, force: :cascade do |t|
    t.integer "budget_investment_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "title"
    t.text "description"
    t.datetime "hidden_at", precision: nil
    t.index ["budget_investment_id"], name: "index_budget_investment_translations_on_budget_investment_id"
    t.index ["hidden_at"], name: "index_budget_investment_translations_on_hidden_at"
    t.index ["locale"], name: "index_budget_investment_translations_on_locale"
  end

  create_table "budget_investments", id: :serial, force: :cascade do |t|
    t.integer "author_id"
    t.integer "administrator_id"
    t.string "external_url"
    t.bigint "price"
    t.string "feasibility", limit: 15, default: "undecided"
    t.text "price_explanation"
    t.text "unfeasibility_explanation"
    t.boolean "valuation_finished", default: false
    t.integer "valuator_assignments_count", default: 0
    t.bigint "price_first_year"
    t.string "duration"
    t.datetime "hidden_at", precision: nil
    t.integer "cached_votes_up", default: 0
    t.integer "comments_count", default: 0
    t.integer "confidence_score", default: 0, null: false
    t.integer "physical_votes", default: 0
    t.tsvector "tsv"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "heading_id"
    t.string "responsible_name"
    t.integer "budget_id"
    t.integer "group_id"
    t.boolean "selected", default: false
    t.string "location"
    t.string "organization_name"
    t.datetime "unfeasible_email_sent_at", precision: nil
    t.integer "ballot_lines_count", default: 0
    t.integer "previous_heading_id"
    t.boolean "winner", default: false
    t.boolean "incompatible", default: false
    t.integer "community_id"
    t.boolean "visible_to_valuators", default: false
    t.integer "valuator_group_assignments_count", default: 0
    t.datetime "confirmed_hide_at", precision: nil
    t.datetime "ignored_flag_at", precision: nil
    t.integer "flags_count", default: 0
    t.integer "original_heading_id"
    t.integer "implementation_performer", default: 0
    t.text "implementation_contribution"
    t.string "user_cost_estimate"
    t.string "on_behalf_of"
    t.integer "qualified_votes_count", default: 0
    t.index ["administrator_id"], name: "index_budget_investments_on_administrator_id"
    t.index ["author_id"], name: "index_budget_investments_on_author_id"
    t.index ["budget_id"], name: "index_budget_investments_on_budget_id"
    t.index ["community_id"], name: "index_budget_investments_on_community_id"
    t.index ["group_id"], name: "index_budget_investments_on_group_id"
    t.index ["heading_id"], name: "index_budget_investments_on_heading_id"
    t.index ["incompatible"], name: "index_budget_investments_on_incompatible"
    t.index ["selected"], name: "index_budget_investments_on_selected"
    t.index ["tsv"], name: "index_budget_investments_on_tsv", using: :gin
  end

  create_table "budget_phase_translations", id: :serial, force: :cascade do |t|
    t.integer "budget_phase_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "description"
    t.text "summary"
    t.string "name"
    t.string "main_link_text"
    t.string "main_link_url"
    t.index ["budget_phase_id"], name: "index_budget_phase_translations_on_budget_phase_id"
    t.index ["locale"], name: "index_budget_phase_translations_on_locale"
  end

  create_table "budget_phases", id: :serial, force: :cascade do |t|
    t.integer "budget_id"
    t.integer "next_phase_id"
    t.string "kind", null: false
    t.datetime "starts_at", precision: nil
    t.datetime "ends_at", precision: nil
    t.boolean "enabled", default: true
    t.index ["ends_at"], name: "index_budget_phases_on_ends_at"
    t.index ["kind"], name: "index_budget_phases_on_kind"
    t.index ["next_phase_id"], name: "index_budget_phases_on_next_phase_id"
    t.index ["starts_at"], name: "index_budget_phases_on_starts_at"
  end

  create_table "budget_reclassified_votes", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "investment_id"
    t.string "reason"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "budget_translations", id: :serial, force: :cascade do |t|
    t.integer "budget_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "name"
    t.string "main_link_text"
    t.string "main_link_url"
    t.index ["budget_id"], name: "index_budget_translations_on_budget_id"
    t.index ["locale"], name: "index_budget_translations_on_locale"
  end

  create_table "budget_valuator_assignments", id: :serial, force: :cascade do |t|
    t.integer "valuator_id"
    t.integer "investment_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["investment_id"], name: "index_budget_valuator_assignments_on_investment_id"
  end

  create_table "budget_valuator_group_assignments", id: :serial, force: :cascade do |t|
    t.integer "valuator_group_id"
    t.integer "investment_id"
  end

  create_table "budget_valuators", id: :serial, force: :cascade do |t|
    t.integer "budget_id"
    t.integer "valuator_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["budget_id"], name: "index_budget_valuators_on_budget_id"
    t.index ["valuator_id"], name: "index_budget_valuators_on_valuator_id"
  end

  create_table "budgets", id: :serial, force: :cascade do |t|
    t.string "currency_symbol", limit: 10
    t.string "phase", limit: 40, default: "accepting"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "description_accepting"
    t.text "description_reviewing"
    t.text "description_selecting"
    t.text "description_valuating"
    t.text "description_balloting"
    t.text "description_reviewing_ballots"
    t.text "description_finished"
    t.string "slug"
    t.text "description_drafting"
    t.text "description_publishing_prices"
    t.text "description_informing"
    t.string "voting_style", default: "knapsack"
    t.boolean "published"
    t.boolean "hide_money", default: false
    t.bigint "projekt_id"
    t.index ["projekt_id"], name: "index_budgets_on_projekt_id"
  end

  create_table "campaigns", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "track_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "ckeditor_assets", id: :serial, force: :cascade do |t|
    t.string "data_file_name", null: false
    t.string "data_content_type"
    t.integer "data_file_size"
    t.string "data_fingerprint"
    t.string "type", limit: 30
    t.integer "width"
    t.integer "height"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["type"], name: "index_ckeditor_assets_on_type"
  end

  create_table "comment_translations", id: :serial, force: :cascade do |t|
    t.integer "comment_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "body"
    t.datetime "hidden_at", precision: nil
    t.index ["comment_id"], name: "index_comment_translations_on_comment_id"
    t.index ["hidden_at"], name: "index_comment_translations_on_hidden_at"
    t.index ["locale"], name: "index_comment_translations_on_locale"
  end

  create_table "comments", id: :serial, force: :cascade do |t|
    t.integer "commentable_id"
    t.string "commentable_type"
    t.string "subject"
    t.integer "user_id", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.datetime "hidden_at", precision: nil
    t.integer "flags_count", default: 0
    t.datetime "ignored_flag_at", precision: nil
    t.integer "moderator_id"
    t.integer "administrator_id"
    t.integer "cached_votes_total", default: 0
    t.integer "cached_votes_up", default: 0
    t.integer "cached_votes_down", default: 0
    t.datetime "confirmed_hide_at", precision: nil
    t.string "ancestry"
    t.integer "confidence_score", default: 0, null: false
    t.boolean "valuation", default: false
    t.tsvector "tsv"
    t.index ["ancestry"], name: "index_comments_on_ancestry"
    t.index ["cached_votes_down"], name: "index_comments_on_cached_votes_down"
    t.index ["cached_votes_total"], name: "index_comments_on_cached_votes_total"
    t.index ["cached_votes_up"], name: "index_comments_on_cached_votes_up"
    t.index ["commentable_id", "commentable_type"], name: "index_comments_on_commentable_id_and_commentable_type"
    t.index ["confidence_score"], name: "index_comments_on_confidence_score"
    t.index ["hidden_at"], name: "index_comments_on_hidden_at"
    t.index ["tsv"], name: "index_comments_on_tsv", using: :gin
    t.index ["user_id"], name: "index_comments_on_user_id"
    t.index ["valuation"], name: "index_comments_on_valuation"
  end

  create_table "communities", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "dashboard_actions", id: :serial, force: :cascade do |t|
    t.string "title", limit: 80
    t.text "description"
    t.boolean "request_to_administrators", default: false
    t.integer "day_offset", default: 0
    t.integer "required_supports", default: 0
    t.integer "order", default: 0
    t.boolean "active", default: true
    t.datetime "hidden_at", precision: nil
    t.integer "action_type", default: 0, null: false
    t.string "short_description"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "published_proposal", default: false
  end

  create_table "dashboard_administrator_tasks", id: :serial, force: :cascade do |t|
    t.string "source_type"
    t.integer "source_id"
    t.integer "user_id"
    t.datetime "executed_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["source_type", "source_id"], name: "index_dashboard_administrator_tasks_on_source"
    t.index ["user_id"], name: "index_dashboard_administrator_tasks_on_user_id"
  end

  create_table "dashboard_executed_actions", id: :serial, force: :cascade do |t|
    t.integer "proposal_id"
    t.integer "action_id"
    t.datetime "executed_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["action_id"], name: "index_proposal_action"
    t.index ["proposal_id"], name: "index_dashboard_executed_actions_on_proposal_id"
  end

  create_table "debate_translations", id: :serial, force: :cascade do |t|
    t.integer "debate_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "title"
    t.text "description"
    t.datetime "hidden_at", precision: nil
    t.index ["debate_id"], name: "index_debate_translations_on_debate_id"
    t.index ["hidden_at"], name: "index_debate_translations_on_hidden_at"
    t.index ["locale"], name: "index_debate_translations_on_locale"
  end

  create_table "debates", id: :serial, force: :cascade do |t|
    t.integer "author_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "hidden_at", precision: nil
    t.integer "flags_count", default: 0
    t.datetime "ignored_flag_at", precision: nil
    t.integer "cached_votes_total", default: 0
    t.integer "cached_votes_up", default: 0
    t.integer "cached_votes_down", default: 0
    t.integer "comments_count", default: 0
    t.datetime "confirmed_hide_at", precision: nil
    t.integer "cached_anonymous_votes_total", default: 0
    t.integer "cached_votes_score", default: 0
    t.bigint "hot_score", default: 0
    t.integer "confidence_score", default: 0
    t.integer "geozone_id"
    t.tsvector "tsv"
    t.datetime "featured_at", precision: nil
    t.bigint "projekt_id"
    t.string "on_behalf_of"
    t.index ["author_id", "hidden_at"], name: "index_debates_on_author_id_and_hidden_at"
    t.index ["author_id"], name: "index_debates_on_author_id"
    t.index ["cached_votes_down"], name: "index_debates_on_cached_votes_down"
    t.index ["cached_votes_score"], name: "index_debates_on_cached_votes_score"
    t.index ["cached_votes_total"], name: "index_debates_on_cached_votes_total"
    t.index ["cached_votes_up"], name: "index_debates_on_cached_votes_up"
    t.index ["confidence_score"], name: "index_debates_on_confidence_score"
    t.index ["geozone_id"], name: "index_debates_on_geozone_id"
    t.index ["hidden_at"], name: "index_debates_on_hidden_at"
    t.index ["hot_score"], name: "index_debates_on_hot_score"
    t.index ["projekt_id"], name: "index_debates_on_projekt_id"
    t.index ["tsv"], name: "index_debates_on_tsv", using: :gin
  end

  create_table "deficiency_report_categories", force: :cascade do |t|
    t.string "color"
    t.string "icon"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "deficiency_report_category_translations", force: :cascade do |t|
    t.bigint "deficiency_report_category_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.index ["deficiency_report_category_id"], name: "index_d61b31ba5bbffdea13be0cd92b8cb671cb6d18b5"
    t.index ["locale"], name: "index_deficiency_report_category_translations_on_locale"
  end

  create_table "deficiency_report_officers", force: :cascade do |t|
    t.bigint "user_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["user_id"], name: "index_deficiency_report_officers_on_user_id"
  end

  create_table "deficiency_report_status_translations", force: :cascade do |t|
    t.bigint "deficiency_report_status_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.text "description"
    t.index ["deficiency_report_status_id"], name: "index_9003f0b89e1dd7ed97cbb6fd7a245a79809763a3"
    t.index ["locale"], name: "index_deficiency_report_status_translations_on_locale"
  end

  create_table "deficiency_report_statuses", force: :cascade do |t|
    t.string "color"
    t.string "icon"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "given_order"
  end

  create_table "deficiency_report_translations", force: :cascade do |t|
    t.bigint "deficiency_report_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.text "description"
    t.text "summary"
    t.text "official_answer"
    t.index ["deficiency_report_id"], name: "index_deficiency_report_translations_on_deficiency_report_id"
    t.index ["locale"], name: "index_deficiency_report_translations_on_locale"
  end

  create_table "deficiency_reports", force: :cascade do |t|
    t.integer "author_id"
    t.integer "comments_count", default: 0
    t.string "video_url"
    t.boolean "official_answer_approved", default: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "deficiency_report_category_id"
    t.bigint "deficiency_report_status_id"
    t.bigint "deficiency_report_officer_id"
    t.integer "cached_votes_total", default: 0
    t.integer "cached_votes_up", default: 0
    t.integer "cached_votes_down", default: 0
    t.integer "cached_votes_score", default: 0
    t.integer "cached_anonymous_votes_total", default: 0
    t.datetime "hidden_at", precision: nil
    t.tsvector "tsv"
    t.bigint "hot_score", default: 0
    t.string "on_behalf_of"
    t.datetime "assigned_at", precision: nil
    t.index ["cached_anonymous_votes_total"], name: "index_deficiency_reports_on_cached_anonymous_votes_total"
    t.index ["cached_votes_down"], name: "index_deficiency_reports_on_cached_votes_down"
    t.index ["cached_votes_score"], name: "index_deficiency_reports_on_cached_votes_score"
    t.index ["cached_votes_total"], name: "index_deficiency_reports_on_cached_votes_total"
    t.index ["cached_votes_up"], name: "index_deficiency_reports_on_cached_votes_up"
    t.index ["deficiency_report_category_id"], name: "index_deficiency_reports_on_deficiency_report_category_id"
    t.index ["deficiency_report_officer_id"], name: "index_deficiency_reports_on_deficiency_report_officer_id"
    t.index ["deficiency_report_status_id"], name: "index_deficiency_reports_on_deficiency_report_status_id"
    t.index ["hidden_at"], name: "index_deficiency_reports_on_hidden_at"
    t.index ["hot_score"], name: "index_deficiency_reports_on_hot_score"
    t.index ["tsv"], name: "index_deficiency_reports_on_tsv", using: :gin
  end

  create_table "delayed_jobs", id: :serial, force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at", precision: nil
    t.datetime "locked_at", precision: nil
    t.datetime "failed_at", precision: nil
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "tenant"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "direct_messages", id: :serial, force: :cascade do |t|
    t.integer "sender_id"
    t.integer "receiver_id"
    t.string "title"
    t.text "body"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "documents", id: :serial, force: :cascade do |t|
    t.string "title"
    t.integer "user_id"
    t.string "documentable_type"
    t.integer "documentable_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "admin", default: false
    t.index ["documentable_type", "documentable_id"], name: "index_documents_on_documentable_type_and_documentable_id"
    t.index ["user_id", "documentable_type", "documentable_id"], name: "access_documents"
    t.index ["user_id"], name: "index_documents_on_user_id"
  end

  create_table "failed_census_calls", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "document_number"
    t.string "document_type"
    t.date "date_of_birth"
    t.string "postal_code"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "district_code"
    t.integer "poll_officer_id"
    t.integer "year_of_birth"
    t.index ["poll_officer_id"], name: "index_failed_census_calls_on_poll_officer_id"
    t.index ["user_id"], name: "index_failed_census_calls_on_user_id"
  end

  create_table "flags", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "flaggable_type"
    t.integer "flaggable_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["flaggable_type", "flaggable_id"], name: "index_flags_on_flaggable_type_and_flaggable_id"
    t.index ["user_id", "flaggable_type", "flaggable_id"], name: "access_inappropiate_flags"
    t.index ["user_id"], name: "index_flags_on_user_id"
  end

  create_table "follows", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "followable_type"
    t.integer "followable_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["followable_type", "followable_id"], name: "index_follows_on_followable_type_and_followable_id"
    t.index ["user_id", "followable_type", "followable_id"], name: "access_follows"
    t.index ["user_id"], name: "index_follows_on_user_id"
  end

  create_table "geozones", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "html_map_coordinates"
    t.string "external_code"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "census_code"
    t.text "geojson"
    t.string "color"
    t.string "postal_codes"
  end

  create_table "geozones_polls", id: :serial, force: :cascade do |t|
    t.integer "geozone_id"
    t.integer "poll_id"
    t.index ["geozone_id"], name: "index_geozones_polls_on_geozone_id"
    t.index ["poll_id"], name: "index_geozones_polls_on_poll_id"
  end

  create_table "geozones_projekts", id: false, force: :cascade do |t|
    t.bigint "geozone_id", null: false
    t.bigint "projekt_id", null: false
    t.index ["projekt_id", "geozone_id"], name: "index_geozones_projekts_on_projekt_id_and_geozone_id", unique: true
  end

  create_table "i18n_content_translations", id: :serial, force: :cascade do |t|
    t.integer "i18n_content_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "value"
    t.index ["i18n_content_id"], name: "index_i18n_content_translations_on_i18n_content_id"
    t.index ["locale"], name: "index_i18n_content_translations_on_locale"
  end

  create_table "i18n_contents", id: :serial, force: :cascade do |t|
    t.string "key"
  end

  create_table "identities", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "provider"
    t.string "uid"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["user_id"], name: "index_identities_on_user_id"
  end

  create_table "images", id: :serial, force: :cascade do |t|
    t.string "imageable_type"
    t.integer "imageable_id"
    t.string "title", limit: 80
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id"
    t.boolean "concealed", default: false
    t.index ["imageable_type", "imageable_id"], name: "index_images_on_imageable_type_and_imageable_id"
    t.index ["user_id"], name: "index_images_on_user_id"
  end

  create_table "legislation_annotations", id: :serial, force: :cascade do |t|
    t.string "quote"
    t.text "ranges"
    t.text "text"
    t.integer "legislation_draft_version_id"
    t.integer "author_id"
    t.datetime "hidden_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "comments_count", default: 0
    t.string "range_start"
    t.integer "range_start_offset"
    t.string "range_end"
    t.integer "range_end_offset"
    t.text "context"
    t.index ["author_id"], name: "index_legislation_annotations_on_author_id"
    t.index ["hidden_at"], name: "index_legislation_annotations_on_hidden_at"
    t.index ["legislation_draft_version_id"], name: "index_legislation_annotations_on_legislation_draft_version_id"
    t.index ["range_start", "range_end"], name: "index_legislation_annotations_on_range_start_and_range_end"
  end

  create_table "legislation_answers", id: :serial, force: :cascade do |t|
    t.integer "legislation_question_id"
    t.integer "legislation_question_option_id"
    t.integer "user_id"
    t.datetime "hidden_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["hidden_at"], name: "index_legislation_answers_on_hidden_at"
    t.index ["legislation_question_id"], name: "index_legislation_answers_on_legislation_question_id"
    t.index ["legislation_question_option_id"], name: "index_legislation_answers_on_legislation_question_option_id"
    t.index ["user_id"], name: "index_legislation_answers_on_user_id"
  end

  create_table "legislation_draft_version_translations", id: :serial, force: :cascade do |t|
    t.integer "legislation_draft_version_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "title"
    t.text "changelog"
    t.text "body"
    t.datetime "hidden_at", precision: nil
    t.index ["hidden_at"], name: "index_legislation_draft_version_translations_on_hidden_at"
    t.index ["legislation_draft_version_id"], name: "index_900e5ba94457606e69e89193db426e8ddff809bc"
    t.index ["locale"], name: "index_legislation_draft_version_translations_on_locale"
  end

  create_table "legislation_draft_versions", id: :serial, force: :cascade do |t|
    t.integer "legislation_process_id"
    t.string "status", default: "draft"
    t.boolean "final_version", default: false
    t.datetime "hidden_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["hidden_at"], name: "index_legislation_draft_versions_on_hidden_at"
    t.index ["legislation_process_id"], name: "index_legislation_draft_versions_on_legislation_process_id"
    t.index ["status"], name: "index_legislation_draft_versions_on_status"
  end

  create_table "legislation_process_translations", id: :serial, force: :cascade do |t|
    t.integer "legislation_process_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "title"
    t.text "summary"
    t.text "description"
    t.text "additional_info"
    t.text "milestones_summary"
    t.text "homepage"
    t.datetime "hidden_at", precision: nil
    t.index ["hidden_at"], name: "index_legislation_process_translations_on_hidden_at"
    t.index ["legislation_process_id"], name: "index_199e5fed0aca73302243f6a1fca885ce10cdbb55"
    t.index ["locale"], name: "index_legislation_process_translations_on_locale"
  end

  create_table "legislation_processes", id: :serial, force: :cascade do |t|
    t.date "start_date"
    t.date "end_date"
    t.date "debate_start_date"
    t.date "debate_end_date"
    t.date "draft_publication_date"
    t.date "allegations_start_date"
    t.date "allegations_end_date"
    t.date "result_publication_date"
    t.datetime "hidden_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "debate_phase_enabled", default: false
    t.boolean "allegations_phase_enabled", default: false
    t.boolean "draft_publication_enabled", default: false
    t.boolean "result_publication_enabled", default: false
    t.boolean "published", default: true
    t.date "proposals_phase_start_date"
    t.date "proposals_phase_end_date"
    t.boolean "proposals_phase_enabled"
    t.text "proposals_description"
    t.date "draft_start_date"
    t.date "draft_end_date"
    t.boolean "draft_phase_enabled", default: false
    t.boolean "homepage_enabled", default: false
    t.text "background_color"
    t.text "font_color"
    t.tsvector "tsv"
    t.bigint "projekt_id"
    t.index ["allegations_end_date"], name: "index_legislation_processes_on_allegations_end_date"
    t.index ["allegations_start_date"], name: "index_legislation_processes_on_allegations_start_date"
    t.index ["debate_end_date"], name: "index_legislation_processes_on_debate_end_date"
    t.index ["debate_start_date"], name: "index_legislation_processes_on_debate_start_date"
    t.index ["draft_end_date"], name: "index_legislation_processes_on_draft_end_date"
    t.index ["draft_publication_date"], name: "index_legislation_processes_on_draft_publication_date"
    t.index ["draft_start_date"], name: "index_legislation_processes_on_draft_start_date"
    t.index ["end_date"], name: "index_legislation_processes_on_end_date"
    t.index ["hidden_at"], name: "index_legislation_processes_on_hidden_at"
    t.index ["projekt_id"], name: "index_legislation_processes_on_projekt_id"
    t.index ["result_publication_date"], name: "index_legislation_processes_on_result_publication_date"
    t.index ["start_date"], name: "index_legislation_processes_on_start_date"
  end

  create_table "legislation_proposals", id: :serial, force: :cascade do |t|
    t.integer "legislation_process_id"
    t.string "title", limit: 80
    t.text "description"
    t.integer "author_id"
    t.datetime "hidden_at", precision: nil
    t.integer "flags_count", default: 0
    t.datetime "ignored_flag_at", precision: nil
    t.integer "cached_votes_up", default: 0
    t.integer "comments_count", default: 0
    t.datetime "confirmed_hide_at", precision: nil
    t.bigint "hot_score", default: 0
    t.integer "confidence_score", default: 0
    t.string "responsible_name", limit: 60
    t.text "summary"
    t.string "video_url"
    t.tsvector "tsv"
    t.integer "geozone_id"
    t.datetime "retired_at", precision: nil
    t.string "retired_reason"
    t.text "retired_explanation"
    t.integer "community_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "cached_votes_total", default: 0
    t.integer "cached_votes_down", default: 0
    t.boolean "selected"
    t.integer "cached_votes_score", default: 0
    t.index ["cached_votes_score"], name: "index_legislation_proposals_on_cached_votes_score"
    t.index ["legislation_process_id"], name: "index_legislation_proposals_on_legislation_process_id"
  end

  create_table "legislation_question_option_translations", id: :serial, force: :cascade do |t|
    t.integer "legislation_question_option_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "value"
    t.datetime "hidden_at", precision: nil
    t.index ["hidden_at"], name: "index_legislation_question_option_translations_on_hidden_at"
    t.index ["legislation_question_option_id"], name: "index_61bcec8729110b7f8e1e9e5ce08780878597a209"
    t.index ["locale"], name: "index_legislation_question_option_translations_on_locale"
  end

  create_table "legislation_question_options", id: :serial, force: :cascade do |t|
    t.integer "legislation_question_id"
    t.integer "answers_count", default: 0
    t.datetime "hidden_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["hidden_at"], name: "index_legislation_question_options_on_hidden_at"
    t.index ["legislation_question_id"], name: "index_legislation_question_options_on_legislation_question_id"
  end

  create_table "legislation_question_translations", id: :serial, force: :cascade do |t|
    t.integer "legislation_question_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "title"
    t.datetime "hidden_at", precision: nil
    t.text "description"
    t.index ["hidden_at"], name: "index_legislation_question_translations_on_hidden_at"
    t.index ["legislation_question_id"], name: "index_d34cc1e1fe6d5162210c41ce56533c5afabcdbd3"
    t.index ["locale"], name: "index_legislation_question_translations_on_locale"
  end

  create_table "legislation_questions", id: :serial, force: :cascade do |t|
    t.integer "legislation_process_id"
    t.integer "answers_count", default: 0
    t.datetime "hidden_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "comments_count", default: 0
    t.integer "author_id"
    t.index ["hidden_at"], name: "index_legislation_questions_on_hidden_at"
    t.index ["legislation_process_id"], name: "index_legislation_questions_on_legislation_process_id"
  end

  create_table "links", id: :serial, force: :cascade do |t|
    t.string "label"
    t.string "url"
    t.string "linkable_type"
    t.integer "linkable_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["linkable_type", "linkable_id"], name: "index_links_on_linkable_type_and_linkable_id"
  end

  create_table "local_census_records", id: :serial, force: :cascade do |t|
    t.string "document_number", null: false
    t.string "document_type", null: false
    t.date "date_of_birth", null: false
    t.string "postal_code", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["document_number", "document_type"], name: "index_local_census_records_on_document_number_and_document_type", unique: true
    t.index ["document_number"], name: "index_local_census_records_on_document_number"
  end

  create_table "locks", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "tries", default: 0
    t.datetime "locked_until", precision: nil, default: "2000-01-01 01:01:01", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["user_id"], name: "index_locks_on_user_id"
  end

  create_table "machine_learning_infos", force: :cascade do |t|
    t.string "kind"
    t.datetime "generated_at", precision: nil
    t.string "script"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "machine_learning_jobs", force: :cascade do |t|
    t.datetime "started_at", precision: nil
    t.datetime "finished_at", precision: nil
    t.string "script"
    t.integer "pid"
    t.string "error"
    t.bigint "user_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["user_id"], name: "index_machine_learning_jobs_on_user_id"
  end

  create_table "managers", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.index ["user_id"], name: "index_managers_on_user_id"
  end

  create_table "map_layers", force: :cascade do |t|
    t.string "name"
    t.string "provider"
    t.string "attribution"
    t.string "layer_names"
    t.boolean "base"
    t.bigint "projekt_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "show_by_default", default: false
    t.boolean "transparent", default: false
    t.integer "protocol", default: 0
    t.index ["projekt_id"], name: "index_map_layers_on_projekt_id"
  end

  create_table "map_locations", id: :serial, force: :cascade do |t|
    t.float "latitude"
    t.float "longitude"
    t.integer "zoom"
    t.integer "proposal_id"
    t.integer "investment_id"
    t.bigint "projekt_id"
    t.string "pin_color"
    t.bigint "deficiency_report_id"
    t.index ["deficiency_report_id"], name: "index_map_locations_on_deficiency_report_id"
    t.index ["investment_id"], name: "index_map_locations_on_investment_id"
    t.index ["projekt_id"], name: "index_map_locations_on_projekt_id"
    t.index ["proposal_id"], name: "index_map_locations_on_proposal_id"
  end

  create_table "milestone_statuses", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "hidden_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["hidden_at"], name: "index_milestone_statuses_on_hidden_at"
  end

  create_table "milestone_translations", id: :serial, force: :cascade do |t|
    t.integer "milestone_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "title"
    t.text "description"
    t.string "custom_date"
    t.index ["locale"], name: "index_milestone_translations_on_locale"
    t.index ["milestone_id"], name: "index_milestone_translations_on_milestone_id"
  end

  create_table "milestones", id: :serial, force: :cascade do |t|
    t.string "milestoneable_type"
    t.integer "milestoneable_id"
    t.datetime "publication_date", precision: nil
    t.integer "status_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["status_id"], name: "index_milestones_on_status_id"
  end

  create_table "ml_summary_comments", force: :cascade do |t|
    t.integer "commentable_id"
    t.string "commentable_type"
    t.text "body"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "moderators", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.index ["user_id"], name: "index_moderators_on_user_id"
  end

  create_table "newsletters", id: :serial, force: :cascade do |t|
    t.string "subject"
    t.string "segment_recipient", null: false
    t.string "from"
    t.text "body"
    t.date "sent_at"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "hidden_at", precision: nil
  end

  create_table "notifications", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "notifiable_type"
    t.integer "notifiable_id"
    t.integer "counter", default: 1
    t.datetime "emailed_at", precision: nil
    t.datetime "read_at", precision: nil
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "organizations", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "name", limit: 60
    t.datetime "verified_at", precision: nil
    t.datetime "rejected_at", precision: nil
    t.string "responsible_name", limit: 60
    t.index ["user_id"], name: "index_organizations_on_user_id"
  end

  create_table "poll_answers", id: :serial, force: :cascade do |t|
    t.integer "question_id"
    t.integer "author_id"
    t.string "answer"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.bigint "option_id"
    t.string "open_answer_text"
    t.index ["author_id"], name: "index_poll_answers_on_author_id"
    t.index ["option_id", "author_id"], name: "index_poll_answers_on_option_id_and_author_id", unique: true
    t.index ["option_id"], name: "index_poll_answers_on_option_id"
    t.index ["question_id", "answer"], name: "index_poll_answers_on_question_id_and_answer"
    t.index ["question_id"], name: "index_poll_answers_on_question_id"
  end

  create_table "poll_ballot_sheets", id: :serial, force: :cascade do |t|
    t.text "data"
    t.integer "poll_id"
    t.integer "officer_assignment_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["officer_assignment_id"], name: "index_poll_ballot_sheets_on_officer_assignment_id"
    t.index ["poll_id"], name: "index_poll_ballot_sheets_on_poll_id"
  end

  create_table "poll_ballots", id: :serial, force: :cascade do |t|
    t.integer "ballot_sheet_id"
    t.text "data"
    t.integer "external_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "poll_booth_assignments", id: :serial, force: :cascade do |t|
    t.integer "booth_id"
    t.integer "poll_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["booth_id"], name: "index_poll_booth_assignments_on_booth_id"
    t.index ["poll_id"], name: "index_poll_booth_assignments_on_poll_id"
  end

  create_table "poll_booths", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "location"
  end

  create_table "poll_officer_assignments", id: :serial, force: :cascade do |t|
    t.integer "booth_assignment_id"
    t.integer "officer_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.date "date", null: false
    t.boolean "final", default: false
    t.string "user_data_log", default: ""
    t.index ["booth_assignment_id"], name: "index_poll_officer_assignments_on_booth_assignment_id"
    t.index ["officer_id"], name: "index_poll_officer_assignments_on_officer_id"
  end

  create_table "poll_officers", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "failed_census_calls_count", default: 0
    t.index ["user_id"], name: "index_poll_officers_on_user_id"
  end

  create_table "poll_partial_results", id: :serial, force: :cascade do |t|
    t.integer "question_id"
    t.integer "author_id"
    t.string "answer"
    t.integer "amount"
    t.string "origin"
    t.date "date"
    t.integer "booth_assignment_id"
    t.integer "officer_assignment_id"
    t.text "amount_log", default: ""
    t.text "officer_assignment_id_log", default: ""
    t.text "author_id_log", default: ""
    t.index ["answer"], name: "index_poll_partial_results_on_answer"
    t.index ["author_id"], name: "index_poll_partial_results_on_author_id"
    t.index ["booth_assignment_id", "date"], name: "index_poll_partial_results_on_booth_assignment_id_and_date"
    t.index ["origin"], name: "index_poll_partial_results_on_origin"
    t.index ["question_id"], name: "index_poll_partial_results_on_question_id"
  end

  create_table "poll_question_answer_translations", id: :serial, force: :cascade do |t|
    t.integer "poll_question_answer_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "title"
    t.text "description"
    t.index ["locale"], name: "index_poll_question_answer_translations_on_locale"
    t.index ["poll_question_answer_id"], name: "index_85270fa85f62081a3a227186b4c95fe4f7fa94b9"
  end

  create_table "poll_question_answer_videos", id: :serial, force: :cascade do |t|
    t.string "title"
    t.string "url"
    t.integer "answer_id"
    t.index ["answer_id"], name: "index_poll_question_answer_videos_on_answer_id"
  end

  create_table "poll_question_answers", id: :serial, force: :cascade do |t|
    t.integer "question_id"
    t.integer "given_order", default: 1
    t.boolean "most_voted", default: false
    t.boolean "open_answer", default: false
    t.integer "rating_scale_weight"
    t.index ["question_id"], name: "index_poll_question_answers_on_question_id"
  end

  create_table "poll_question_translations", id: :serial, force: :cascade do |t|
    t.integer "poll_question_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "title"
    t.datetime "hidden_at", precision: nil
    t.text "description"
    t.index ["hidden_at"], name: "index_poll_question_translations_on_hidden_at"
    t.index ["locale"], name: "index_poll_question_translations_on_locale"
    t.index ["poll_question_id"], name: "index_poll_question_translations_on_poll_question_id"
  end

  create_table "poll_questions", id: :serial, force: :cascade do |t|
    t.integer "proposal_id"
    t.integer "poll_id"
    t.integer "author_id"
    t.string "author_visible_name"
    t.integer "comments_count"
    t.datetime "hidden_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.tsvector "tsv"
    t.string "video_url"
    t.boolean "show_images", default: false
    t.boolean "multiple", default: false
    t.integer "given_order"
    t.index ["author_id"], name: "index_poll_questions_on_author_id"
    t.index ["poll_id"], name: "index_poll_questions_on_poll_id"
    t.index ["proposal_id"], name: "index_poll_questions_on_proposal_id"
    t.index ["tsv"], name: "index_poll_questions_on_tsv", using: :gin
  end

  create_table "poll_recounts", id: :serial, force: :cascade do |t|
    t.integer "author_id"
    t.string "origin"
    t.date "date"
    t.integer "booth_assignment_id"
    t.integer "officer_assignment_id"
    t.text "officer_assignment_id_log", default: ""
    t.text "author_id_log", default: ""
    t.integer "white_amount", default: 0
    t.text "white_amount_log", default: ""
    t.integer "null_amount", default: 0
    t.text "null_amount_log", default: ""
    t.integer "total_amount", default: 0
    t.text "total_amount_log", default: ""
    t.index ["booth_assignment_id"], name: "index_poll_recounts_on_booth_assignment_id"
    t.index ["officer_assignment_id"], name: "index_poll_recounts_on_officer_assignment_id"
  end

  create_table "poll_shifts", id: :serial, force: :cascade do |t|
    t.integer "booth_id"
    t.integer "officer_id"
    t.date "date"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "officer_name"
    t.string "officer_email"
    t.integer "task", default: 0, null: false
    t.index ["booth_id", "officer_id", "date", "task"], name: "index_poll_shifts_on_booth_id_and_officer_id_and_date_and_task", unique: true
    t.index ["booth_id"], name: "index_poll_shifts_on_booth_id"
    t.index ["officer_id"], name: "index_poll_shifts_on_officer_id"
  end

  create_table "poll_translations", id: :serial, force: :cascade do |t|
    t.integer "poll_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "name"
    t.text "summary"
    t.text "description"
    t.datetime "hidden_at", precision: nil
    t.index ["hidden_at"], name: "index_poll_translations_on_hidden_at"
    t.index ["locale"], name: "index_poll_translations_on_locale"
    t.index ["poll_id"], name: "index_poll_translations_on_poll_id"
  end

  create_table "poll_voters", id: :serial, force: :cascade do |t|
    t.string "document_number"
    t.string "document_type"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "poll_id", null: false
    t.integer "booth_assignment_id"
    t.integer "age"
    t.string "gender"
    t.integer "geozone_id"
    t.integer "officer_assignment_id"
    t.integer "user_id"
    t.string "origin"
    t.integer "officer_id"
    t.index ["booth_assignment_id"], name: "index_poll_voters_on_booth_assignment_id"
    t.index ["document_number"], name: "index_poll_voters_on_document_number"
    t.index ["officer_assignment_id"], name: "index_poll_voters_on_officer_assignment_id"
    t.index ["poll_id", "document_number", "document_type"], name: "doc_by_poll"
    t.index ["poll_id"], name: "index_poll_voters_on_poll_id"
    t.index ["user_id"], name: "index_poll_voters_on_user_id"
  end

  create_table "polls", id: :serial, force: :cascade do |t|
    t.datetime "starts_at", precision: nil
    t.datetime "ends_at", precision: nil
    t.boolean "published", default: false
    t.boolean "geozone_restricted", default: false
    t.integer "comments_count", default: 0
    t.integer "author_id"
    t.datetime "hidden_at", precision: nil
    t.string "slug"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "budget_id"
    t.string "related_type"
    t.integer "related_id"
    t.tsvector "tsv"
    t.bigint "projekt_id"
    t.boolean "show_open_answer_author_name"
    t.boolean "show_summary_instead_of_questions", default: false
    t.boolean "show_on_home_page", default: true
    t.boolean "show_on_index_page", default: true
    t.index ["budget_id"], name: "index_polls_on_budget_id", unique: true
    t.index ["geozone_restricted"], name: "index_polls_on_geozone_restricted"
    t.index ["projekt_id"], name: "index_polls_on_projekt_id"
    t.index ["related_type", "related_id"], name: "index_polls_on_related_type_and_related_id"
    t.index ["starts_at", "ends_at"], name: "index_polls_on_starts_at_and_ends_at"
  end

  create_table "progress_bar_translations", id: :serial, force: :cascade do |t|
    t.integer "progress_bar_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "title"
    t.index ["locale"], name: "index_progress_bar_translations_on_locale"
    t.index ["progress_bar_id"], name: "index_progress_bar_translations_on_progress_bar_id"
  end

  create_table "progress_bars", id: :serial, force: :cascade do |t|
    t.integer "kind"
    t.integer "percentage"
    t.string "progressable_type"
    t.integer "progressable_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "projekt_arguments", force: :cascade do |t|
    t.string "name"
    t.string "party"
    t.boolean "pro"
    t.string "position"
    t.text "note"
    t.integer "projekt_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["projekt_id"], name: "index_projekt_arguments_on_projekt_id"
  end

  create_table "projekt_events", force: :cascade do |t|
    t.string "title"
    t.string "location"
    t.datetime "datetime", precision: nil
    t.string "weblink"
    t.integer "projekt_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "description"
    t.datetime "end_datetime", precision: nil
  end

  create_table "projekt_livestreams", force: :cascade do |t|
    t.string "url"
    t.string "video_platform"
    t.string "title"
    t.datetime "starts_at", precision: nil
    t.text "description"
    t.bigint "projekt_id"
    t.string "external_id"
    t.string "preview_image_url"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["projekt_id"], name: "index_projekt_livestreams_on_projekt_id"
  end

  create_table "projekt_manager_assignments", force: :cascade do |t|
    t.bigint "projekt_id"
    t.bigint "projekt_manager_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["projekt_id"], name: "index_projekt_manager_assignments_on_projekt_id"
    t.index ["projekt_manager_id"], name: "index_projekt_manager_assignments_on_projekt_manager_id"
  end

  create_table "projekt_managers", force: :cascade do |t|
    t.bigint "user_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["user_id"], name: "index_projekt_managers_on_user_id"
  end

  create_table "projekt_notifications", force: :cascade do |t|
    t.bigint "projekt_id"
    t.string "title"
    t.text "body"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["projekt_id"], name: "index_projekt_notifications_on_projekt_id"
  end

  create_table "projekt_phase_geozones", force: :cascade do |t|
    t.bigint "projekt_phase_id"
    t.bigint "geozone_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["geozone_id"], name: "index_projekt_phase_geozones_on_geozone_id"
    t.index ["projekt_phase_id"], name: "index_projekt_phase_geozones_on_projekt_phase_id"
  end

  create_table "projekt_phase_translations", force: :cascade do |t|
    t.bigint "projekt_phase_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "phase_tab_name"
    t.text "resource_form_title"
    t.index ["locale"], name: "index_projekt_phase_translations_on_locale"
    t.index ["projekt_phase_id"], name: "index_projekt_phase_translations_on_projekt_phase_id"
  end

  create_table "projekt_phases", force: :cascade do |t|
    t.string "type"
    t.date "start_date"
    t.date "end_date"
    t.string "geozone_restricted"
    t.bigint "projekt_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "active"
    t.boolean "verification_restricted", default: false
    t.bigint "age_restriction_id"
    t.index ["age_restriction_id"], name: "index_projekt_phases_on_age_restriction_id"
    t.index ["projekt_id"], name: "index_projekt_phases_on_projekt_id"
  end

  create_table "projekt_question_answers", force: :cascade do |t|
    t.bigint "projekt_question_id"
    t.bigint "projekt_question_option_id"
    t.bigint "user_id"
    t.datetime "hidden_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["hidden_at"], name: "index_projekt_question_answers_on_hidden_at"
    t.index ["projekt_question_id"], name: "index_projekt_question_answers_on_projekt_question_id"
    t.index ["projekt_question_option_id"], name: "index_projekt_question_answers_on_projekt_question_option_id"
    t.index ["user_id"], name: "index_projekt_question_answers_on_user_id"
  end

  create_table "projekt_question_option_translations", force: :cascade do |t|
    t.bigint "projekt_question_option_id"
    t.string "locale", null: false
    t.string "value"
    t.datetime "hidden_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["projekt_question_option_id"], name: "option_projekt_question_option_id"
  end

  create_table "projekt_question_options", force: :cascade do |t|
    t.bigint "projekt_question_id"
    t.integer "answers_count", default: 0
    t.datetime "hidden_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["hidden_at"], name: "index_projekt_question_options_on_hidden_at"
    t.index ["projekt_question_id"], name: "index_projekt_question_options_on_projekt_question_id"
  end

  create_table "projekt_question_translations", force: :cascade do |t|
    t.bigint "projekt_question_id"
    t.string "locale", null: false
    t.text "title"
    t.datetime "hidden_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["locale"], name: "index_projekt_question_translations_on_locale"
    t.index ["projekt_question_id"], name: "index_projekt_question_translations_on_projekt_question_id"
  end

  create_table "projekt_questions", force: :cascade do |t|
    t.text "title"
    t.integer "answers_count", default: 0
    t.integer "comments_count", default: 0
    t.integer "author_id", default: 0
    t.datetime "hidden_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "projekt_id"
    t.boolean "comments_enabled", default: true
    t.boolean "show_answers_count", default: true
    t.integer "projekt_livestream_id"
    t.index ["hidden_at"], name: "index_projekt_questions_on_hidden_at"
    t.index ["projekt_id"], name: "index_projekt_questions_on_projekt_id"
    t.index ["projekt_livestream_id"], name: "index_projekt_questions_on_projekt_livestream_id"
  end

  create_table "projekt_settings", force: :cascade do |t|
    t.bigint "projekt_id"
    t.string "key"
    t.string "value"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["projekt_id"], name: "index_projekt_settings_on_projekt_id"
  end

  create_table "projekt_translations", force: :cascade do |t|
    t.bigint "projekt_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.index ["locale"], name: "index_projekt_translations_on_locale"
    t.index ["projekt_id"], name: "index_projekt_translations_on_projekt_id"
  end

  create_table "projekts", force: :cascade do |t|
    t.string "name"
    t.bigint "parent_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "order_number"
    t.date "total_duration_start"
    t.date "total_duration_end"
    t.integer "comments_count", default: 0
    t.datetime "hidden_at", precision: nil
    t.integer "author_id"
    t.string "geozone_affiliated"
    t.string "color"
    t.string "icon"
    t.integer "level", default: 1
    t.boolean "special", default: false
    t.string "special_name"
    t.boolean "show_start_date_in_frontend", default: true
    t.boolean "show_end_date_in_frontend", default: true
    t.index ["parent_id"], name: "index_projekts_on_parent_id"
  end

  create_table "proposal_notifications", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.integer "author_id"
    t.integer "proposal_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "moderated", default: false
    t.datetime "hidden_at", precision: nil
    t.datetime "ignored_at", precision: nil
    t.datetime "confirmed_hide_at", precision: nil
    t.tsvector "tsv"
    t.index ["tsv"], name: "index_proposal_notifications_on_tsv", using: :gin
  end

  create_table "proposal_translations", id: :serial, force: :cascade do |t|
    t.integer "proposal_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "title"
    t.text "description"
    t.text "summary"
    t.text "retired_explanation"
    t.datetime "hidden_at", precision: nil
    t.index ["hidden_at"], name: "index_proposal_translations_on_hidden_at"
    t.index ["locale"], name: "index_proposal_translations_on_locale"
    t.index ["proposal_id"], name: "index_proposal_translations_on_proposal_id"
  end

  create_table "proposals", id: :serial, force: :cascade do |t|
    t.integer "author_id"
    t.datetime "hidden_at", precision: nil
    t.integer "flags_count", default: 0
    t.datetime "ignored_flag_at", precision: nil
    t.integer "cached_votes_up", default: 0
    t.integer "comments_count", default: 0
    t.datetime "confirmed_hide_at", precision: nil
    t.bigint "hot_score", default: 0
    t.integer "confidence_score", default: 0
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "responsible_name", limit: 60
    t.string "video_url"
    t.tsvector "tsv"
    t.integer "geozone_id"
    t.datetime "retired_at", precision: nil
    t.string "retired_reason"
    t.integer "community_id"
    t.datetime "published_at", precision: nil
    t.boolean "selected", default: false
    t.bigint "projekt_id"
    t.string "on_behalf_of"
    t.index ["author_id", "hidden_at"], name: "index_proposals_on_author_id_and_hidden_at"
    t.index ["author_id"], name: "index_proposals_on_author_id"
    t.index ["cached_votes_up"], name: "index_proposals_on_cached_votes_up"
    t.index ["community_id"], name: "index_proposals_on_community_id"
    t.index ["confidence_score"], name: "index_proposals_on_confidence_score"
    t.index ["geozone_id"], name: "index_proposals_on_geozone_id"
    t.index ["hidden_at"], name: "index_proposals_on_hidden_at"
    t.index ["hot_score"], name: "index_proposals_on_hot_score"
    t.index ["projekt_id"], name: "index_proposals_on_projekt_id"
    t.index ["selected"], name: "index_proposals_on_selected"
    t.index ["tsv"], name: "index_proposals_on_tsv", using: :gin
  end

  create_table "related_content_scores", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "related_content_id"
    t.integer "value"
    t.index ["related_content_id"], name: "index_related_content_scores_on_related_content_id"
    t.index ["user_id", "related_content_id"], name: "unique_user_related_content_scoring", unique: true
    t.index ["user_id"], name: "index_related_content_scores_on_user_id"
  end

  create_table "related_contents", id: :serial, force: :cascade do |t|
    t.string "parent_relationable_type"
    t.integer "parent_relationable_id"
    t.string "child_relationable_type"
    t.integer "child_relationable_id"
    t.integer "related_content_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.datetime "hidden_at", precision: nil
    t.integer "related_content_scores_count", default: 0
    t.integer "author_id"
    t.boolean "machine_learning", default: false
    t.integer "machine_learning_score", default: 0
    t.index ["child_relationable_type", "child_relationable_id"], name: "index_related_contents_on_child_relationable"
    t.index ["hidden_at"], name: "index_related_contents_on_hidden_at"
    t.index ["parent_relationable_id", "parent_relationable_type", "child_relationable_id", "child_relationable_type"], name: "unique_parent_child_related_content", unique: true
    t.index ["parent_relationable_type", "parent_relationable_id"], name: "index_related_contents_on_parent_relationable"
    t.index ["related_content_id"], name: "opposite_related_content"
  end

  create_table "remote_translations", id: :serial, force: :cascade do |t|
    t.string "locale"
    t.integer "remote_translatable_id"
    t.string "remote_translatable_type"
    t.text "error_message"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "reports", id: :serial, force: :cascade do |t|
    t.boolean "stats"
    t.boolean "results"
    t.string "process_type"
    t.integer "process_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "advanced_stats"
    t.index ["process_type", "process_id"], name: "index_reports_on_process_type_and_process_id"
  end

  create_table "sdg_goals", force: :cascade do |t|
    t.integer "code", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["code"], name: "index_sdg_goals_on_code", unique: true
  end

  create_table "sdg_local_target_translations", force: :cascade do |t|
    t.bigint "sdg_local_target_id", null: false
    t.string "locale", null: false
    t.string "title"
    t.text "description"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["locale"], name: "index_sdg_local_target_translations_on_locale"
    t.index ["sdg_local_target_id"], name: "index_sdg_local_target_translations_on_sdg_local_target_id"
  end

  create_table "sdg_local_targets", force: :cascade do |t|
    t.bigint "target_id"
    t.string "code"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "goal_id"
    t.index ["code"], name: "index_sdg_local_targets_on_code", unique: true
    t.index ["goal_id"], name: "index_sdg_local_targets_on_goal_id"
    t.index ["target_id"], name: "index_sdg_local_targets_on_target_id"
  end

  create_table "sdg_managers", force: :cascade do |t|
    t.bigint "user_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["user_id"], name: "index_sdg_managers_on_user_id", unique: true
  end

  create_table "sdg_phases", force: :cascade do |t|
    t.integer "kind", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["kind"], name: "index_sdg_phases_on_kind", unique: true
  end

  create_table "sdg_relations", force: :cascade do |t|
    t.string "related_sdg_type"
    t.bigint "related_sdg_id"
    t.string "relatable_type"
    t.bigint "relatable_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["relatable_type", "relatable_id"], name: "index_sdg_relations_on_relatable_type_and_relatable_id"
    t.index ["related_sdg_id", "related_sdg_type", "relatable_id", "relatable_type"], name: "sdg_relations_unique", unique: true
    t.index ["related_sdg_type", "related_sdg_id"], name: "index_sdg_relations_on_related_sdg_type_and_related_sdg_id"
  end

  create_table "sdg_reviews", force: :cascade do |t|
    t.string "relatable_type"
    t.bigint "relatable_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["relatable_type", "relatable_id"], name: "index_sdg_reviews_on_relatable_type_and_relatable_id", unique: true
  end

  create_table "sdg_targets", force: :cascade do |t|
    t.bigint "goal_id"
    t.string "code", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["code"], name: "index_sdg_targets_on_code", unique: true
    t.index ["goal_id"], name: "index_sdg_targets_on_goal_id"
  end

  create_table "settings", id: :serial, force: :cascade do |t|
    t.string "key"
    t.string "value"
    t.index ["key"], name: "index_settings_on_key"
  end

  create_table "signature_sheets", id: :serial, force: :cascade do |t|
    t.string "signable_type"
    t.integer "signable_id"
    t.text "required_fields_to_verify"
    t.boolean "processed", default: false
    t.integer "author_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "title"
  end

  create_table "signatures", id: :serial, force: :cascade do |t|
    t.integer "signature_sheet_id"
    t.integer "user_id"
    t.string "document_number"
    t.boolean "verified", default: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.date "date_of_birth"
    t.string "postal_code"
  end

  create_table "site_customization_content_blocks", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "locale"
    t.text "body"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "key"
    t.index ["key", "name", "locale"], name: "locale_key_name_index", unique: true
  end

  create_table "site_customization_images", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "image_file_name"
    t.string "image_content_type"
    t.bigint "image_file_size"
    t.datetime "image_updated_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["name"], name: "index_site_customization_images_on_name", unique: true
  end

  create_table "site_customization_page_translations", id: :serial, force: :cascade do |t|
    t.integer "site_customization_page_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "title"
    t.string "subtitle"
    t.text "content"
    t.index ["locale"], name: "index_site_customization_page_translations_on_locale"
    t.index ["site_customization_page_id"], name: "index_7fa0f9505738cb31a31f11fb2f4c4531fed7178b"
  end

  create_table "site_customization_pages", id: :serial, force: :cascade do |t|
    t.string "slug", null: false
    t.boolean "more_info_flag"
    t.boolean "print_content_flag"
    t.string "status", default: "draft"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "locale"
    t.bigint "projekt_id"
    t.index ["projekt_id"], name: "index_site_customization_pages_on_projekt_id"
  end

  create_table "taggings", id: :serial, force: :cascade do |t|
    t.integer "tag_id"
    t.string "taggable_type"
    t.integer "taggable_id"
    t.string "tagger_type"
    t.integer "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at", precision: nil
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "name", limit: 160
    t.integer "taggings_count", default: 0
    t.integer "debates_count", default: 0
    t.integer "proposals_count", default: 0
    t.string "kind"
    t.integer "budget_investments_count", default: 0
    t.integer "legislation_proposals_count", default: 0
    t.integer "legislation_processes_count", default: 0
    t.integer "polls_count", default: 0
    t.integer "custom_logic_category_code", default: 0
    t.integer "custom_logic_subcategory_code", default: 0
    t.boolean "custom_logic_category_cloud"
    t.boolean "custom_logic_subcategory_cloud"
    t.boolean "custom_logic_usertags_cloud"
    t.integer "projekts_count", default: 0
    t.index ["debates_count"], name: "index_tags_on_debates_count"
    t.index ["legislation_processes_count"], name: "index_tags_on_legislation_processes_count"
    t.index ["legislation_proposals_count"], name: "index_tags_on_legislation_proposals_count"
    t.index ["name"], name: "index_tags_on_name", unique: true
    t.index ["proposals_count"], name: "index_tags_on_proposals_count"
  end

  create_table "tenants", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "schema"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "schema_type", default: 0, null: false
    t.datetime "hidden_at", precision: nil
    t.index ["name"], name: "index_tenants_on_name", unique: true
    t.index ["schema"], name: "index_tenants_on_schema", unique: true
  end

  create_table "topics", id: :serial, force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.integer "author_id"
    t.integer "comments_count", default: 0
    t.integer "community_id"
    t.datetime "hidden_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["community_id"], name: "index_topics_on_community_id"
    t.index ["hidden_at"], name: "index_topics_on_hidden_at"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: ""
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "confirmation_sent_at", precision: nil
    t.string "unconfirmed_email"
    t.boolean "email_on_comment", default: false
    t.boolean "email_on_comment_reply", default: false
    t.string "phone_number", limit: 30
    t.string "official_position"
    t.integer "official_level", default: 0
    t.datetime "hidden_at", precision: nil
    t.string "sms_confirmation_code"
    t.string "username", limit: 60
    t.string "document_number"
    t.string "document_type"
    t.datetime "residence_verified_at", precision: nil
    t.string "email_verification_token"
    t.datetime "verified_at", precision: nil
    t.string "unconfirmed_phone"
    t.string "confirmed_phone"
    t.datetime "letter_requested_at", precision: nil
    t.datetime "confirmed_hide_at", precision: nil
    t.string "letter_verification_code"
    t.integer "failed_census_calls_count", default: 0
    t.datetime "level_two_verified_at", precision: nil
    t.string "erase_reason"
    t.datetime "erased_at", precision: nil
    t.boolean "public_activity", default: true
    t.boolean "newsletter", default: true
    t.integer "notifications_count", default: 0
    t.boolean "registering_with_oauth", default: false
    t.string "locale"
    t.string "oauth_email"
    t.integer "geozone_id"
    t.string "redeemable_code"
    t.string "gender", limit: 10
    t.datetime "date_of_birth", precision: nil
    t.boolean "email_digest", default: true
    t.boolean "email_on_direct_message", default: true
    t.boolean "official_position_badge", default: false
    t.datetime "password_changed_at", precision: nil, default: "2015-01-01 01:01:01", null: false
    t.boolean "created_from_signature", default: false
    t.integer "failed_email_digests_count", default: 0
    t.text "former_users_data_log", default: ""
    t.boolean "public_interests", default: false
    t.boolean "recommended_debates", default: true
    t.boolean "recommended_proposals", default: true
    t.string "subscriptions_token"
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "locked_at", precision: nil
    t.string "unlock_token"
    t.string "street_number"
    t.string "document_last_digits"
    t.string "first_name"
    t.string "last_name"
    t.string "street_name"
    t.integer "plz"
    t.string "city_name"
    t.string "unique_stamp"
    t.boolean "adm_email_on_new_comment", default: false
    t.boolean "adm_email_on_new_proposal", default: false
    t.boolean "adm_email_on_new_debate", default: false
    t.boolean "adm_email_on_new_deficiency_report", default: false
    t.string "otp_secret"
    t.integer "consumed_timestep"
    t.boolean "otp_required_for_login"
    t.text "otp_backup_codes"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["date_of_birth"], name: "index_users_on_date_of_birth"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["gender"], name: "index_users_on_gender"
    t.index ["geozone_id"], name: "index_users_on_geozone_id"
    t.index ["hidden_at"], name: "index_users_on_hidden_at"
    t.index ["password_changed_at"], name: "index_users_on_password_changed_at"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
    t.index ["username"], name: "index_users_on_username"
  end

  create_table "valuator_groups", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "budget_investments_count", default: 0
  end

  create_table "valuators", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "description"
    t.integer "budget_investments_count", default: 0
    t.integer "valuator_group_id"
    t.boolean "can_comment", default: true
    t.boolean "can_edit_dossier", default: true
    t.index ["user_id"], name: "index_valuators_on_user_id"
  end

  create_table "verified_users", id: :serial, force: :cascade do |t|
    t.string "document_number"
    t.string "document_type"
    t.string "phone"
    t.string "email"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["document_number"], name: "index_verified_users_on_document_number"
    t.index ["email"], name: "index_verified_users_on_email"
    t.index ["phone"], name: "index_verified_users_on_phone"
  end

  create_table "visits", id: :uuid, default: nil, force: :cascade do |t|
    t.uuid "visitor_id"
    t.string "ip"
    t.text "user_agent"
    t.text "referrer"
    t.text "landing_page"
    t.integer "user_id"
    t.string "referring_domain"
    t.string "search_keyword"
    t.string "browser"
    t.string "os"
    t.string "device_type"
    t.integer "screen_height"
    t.integer "screen_width"
    t.string "country"
    t.string "region"
    t.string "city"
    t.string "postal_code"
    t.decimal "latitude"
    t.decimal "longitude"
    t.string "utm_source"
    t.string "utm_medium"
    t.string "utm_term"
    t.string "utm_content"
    t.string "utm_campaign"
    t.datetime "started_at", precision: nil
    t.index ["started_at"], name: "index_visits_on_started_at"
    t.index ["user_id"], name: "index_visits_on_user_id"
    t.index ["visitor_id", "started_at"], name: "index_visits_on_visitor_id_and_started_at"
  end

  create_table "votation_types", force: :cascade do |t|
    t.integer "questionable_id"
    t.string "questionable_type"
    t.integer "vote_type"
    t.integer "max_votes"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "votes", id: :serial, force: :cascade do |t|
    t.string "votable_type"
    t.integer "votable_id"
    t.string "voter_type"
    t.integer "voter_id"
    t.boolean "vote_flag"
    t.string "vote_scope"
    t.integer "vote_weight"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "signature_id"
    t.index ["signature_id"], name: "index_votes_on_signature_id"
    t.index ["votable_id", "votable_type", "vote_scope"], name: "index_votes_on_votable_id_and_votable_type_and_vote_scope"
    t.index ["voter_id", "voter_type", "vote_scope"], name: "index_votes_on_voter_id_and_voter_type_and_vote_scope"
  end

  create_table "web_sections", id: :serial, force: :cascade do |t|
    t.text "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "widget_card_translations", id: :serial, force: :cascade do |t|
    t.integer "widget_card_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "label"
    t.string "title"
    t.text "description"
    t.string "link_text"
    t.index ["locale"], name: "index_widget_card_translations_on_locale"
    t.index ["widget_card_id"], name: "index_widget_card_translations_on_widget_card_id"
  end

  create_table "widget_cards", id: :serial, force: :cascade do |t|
    t.string "link_url"
    t.boolean "header", default: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "cardable_id"
    t.integer "columns", default: 4
    t.string "cardable_type", default: "SiteCustomization::Page"
    t.integer "order", default: 1, null: false
    t.string "card_category", default: ""
    t.index ["cardable_id"], name: "index_widget_cards_on_cardable_id"
  end

  create_table "widget_feeds", id: :serial, force: :cascade do |t|
    t.string "kind"
    t.integer "limit", default: 3
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "administrators", "users"
  add_foreign_key "budget_administrators", "administrators"
  add_foreign_key "budget_administrators", "budgets"
  add_foreign_key "budget_headings", "geozones"
  add_foreign_key "budget_investments", "communities"
  add_foreign_key "budget_valuators", "budgets"
  add_foreign_key "budget_valuators", "valuators"
  add_foreign_key "budgets", "projekts"
  add_foreign_key "dashboard_administrator_tasks", "users"
  add_foreign_key "dashboard_executed_actions", "dashboard_actions", column: "action_id"
  add_foreign_key "dashboard_executed_actions", "proposals"
  add_foreign_key "debates", "projekts"
  add_foreign_key "deficiency_report_officers", "users"
  add_foreign_key "deficiency_reports", "deficiency_report_categories"
  add_foreign_key "deficiency_reports", "deficiency_report_officers"
  add_foreign_key "deficiency_reports", "deficiency_report_statuses"
  add_foreign_key "documents", "users"
  add_foreign_key "failed_census_calls", "poll_officers"
  add_foreign_key "failed_census_calls", "users"
  add_foreign_key "flags", "users"
  add_foreign_key "follows", "users"
  add_foreign_key "geozones_polls", "geozones"
  add_foreign_key "geozones_polls", "polls"
  add_foreign_key "identities", "users"
  add_foreign_key "images", "users"
  add_foreign_key "legislation_draft_versions", "legislation_processes"
  add_foreign_key "legislation_processes", "projekts"
  add_foreign_key "legislation_proposals", "legislation_processes"
  add_foreign_key "locks", "users"
  add_foreign_key "machine_learning_jobs", "users"
  add_foreign_key "managers", "users"
  add_foreign_key "map_layers", "projekts"
  add_foreign_key "map_locations", "deficiency_reports"
  add_foreign_key "map_locations", "projekts"
  add_foreign_key "moderators", "users"
  add_foreign_key "notifications", "users"
  add_foreign_key "organizations", "users"
  add_foreign_key "poll_answers", "poll_question_answers", column: "option_id"
  add_foreign_key "poll_answers", "poll_questions", column: "question_id"
  add_foreign_key "poll_booth_assignments", "polls"
  add_foreign_key "poll_officer_assignments", "poll_booth_assignments", column: "booth_assignment_id"
  add_foreign_key "poll_partial_results", "poll_booth_assignments", column: "booth_assignment_id"
  add_foreign_key "poll_partial_results", "poll_officer_assignments", column: "officer_assignment_id"
  add_foreign_key "poll_partial_results", "poll_questions", column: "question_id"
  add_foreign_key "poll_partial_results", "users", column: "author_id"
  add_foreign_key "poll_question_answer_videos", "poll_question_answers", column: "answer_id"
  add_foreign_key "poll_question_answers", "poll_questions", column: "question_id"
  add_foreign_key "poll_questions", "polls"
  add_foreign_key "poll_questions", "proposals"
  add_foreign_key "poll_questions", "users", column: "author_id"
  add_foreign_key "poll_recounts", "poll_booth_assignments", column: "booth_assignment_id"
  add_foreign_key "poll_recounts", "poll_officer_assignments", column: "officer_assignment_id"
  add_foreign_key "poll_voters", "polls"
  add_foreign_key "polls", "budgets"
  add_foreign_key "polls", "projekts"
  add_foreign_key "projekt_manager_assignments", "projekt_managers"
  add_foreign_key "projekt_manager_assignments", "projekts"
  add_foreign_key "projekt_managers", "users"
  add_foreign_key "projekt_notifications", "projekts"
  add_foreign_key "projekt_phase_geozones", "geozones"
  add_foreign_key "projekt_phase_geozones", "projekt_phases"
  add_foreign_key "projekt_phases", "age_restrictions"
  add_foreign_key "projekt_phases", "projekts"
  add_foreign_key "projekt_settings", "projekts"
  add_foreign_key "projekts", "projekts", column: "parent_id"
  add_foreign_key "proposals", "communities"
  add_foreign_key "proposals", "projekts"
  add_foreign_key "related_content_scores", "related_contents"
  add_foreign_key "related_content_scores", "users"
  add_foreign_key "sdg_managers", "users"
  add_foreign_key "site_customization_pages", "projekts"
  add_foreign_key "users", "geozones"
  add_foreign_key "valuators", "users"
end
