require 'rails_helper'
require 'migrations/legacy_legislation/annotation'

describe Migrations::LegacyLegislation::Annotation do

  let(:migration) { Migrations::LegacyLegislation::Annotation.new }
  let(:info) do
    [
      { old_id: 1, new_id: 10 },
      { old_id: 2, new_id: 20 }
    ]
  end

  before do
    (1..2).each do |n|
      old_process = create :legacy_legislation, id: n
      3.times do
        create :annotation, legacy_legislation: old_process, user: create(:user)
      end

      new_process = create :legislation_process, id: n * 10
      create :legislation_draft_version, process: new_process
    end

    allow(migration).to receive(:processes_info).and_return(info)
  end

  scenario "Migrate all annotations from old processes to new processes" do
    migration.migrate_annotations

    expect(Legislation::Process.count).to be 2
    expect(Legislation::Annotation.count).to be 6

    info.each do |info|
      old_process = LegacyLegislation.find info[:old_id]
      new_process = Legislation::Process.find info[:new_id]
      new_draft = new_process.draft_versions.first

      expect(new_draft.annotations.count).to eq old_process.annotations.count

      old_annotation = old_process.annotations.order(:id).last
      new_annotation = new_draft.annotations.order(:id).last
      expect(new_annotation.quote).to eq old_annotation.quote
      expect(new_annotation.ranges).to eq old_annotation.ranges
      expect(new_annotation.text).to eq old_annotation.text
      expect(new_annotation.author_id).to eq old_annotation.user_id
      expect(new_annotation.created_at).to eq old_annotation.created_at
      expect(new_annotation.updated_at).to eq old_annotation.updated_at
      expect(new_annotation.comments_count).to be 1
      expect(new_annotation.range_start).to eq old_annotation.ranges.first['start']
      expect(new_annotation.range_start_offset).to eq old_annotation.ranges.first['startOffset']
      expect(new_annotation.range_end).to eq old_annotation.ranges.first['end']
      expect(new_annotation.range_end_offset).to eq old_annotation.ranges.first['endOffset']
      expect(new_annotation.context).to eq "<span class=annotator-hl>#{old_annotation.quote}</span>"

      expect(new_process.end_date). to eq new_annotation.created_at.to_date
      expect(new_process.allegations_end_date). to eq new_annotation.created_at.to_date
      expect(new_process.updated_at). to eq new_annotation.created_at
    end
  end

  scenario "Undo migrate all annotations" do
    migration.migrate_annotations
    expect(Legislation::Annotation.count).to be 6

    migration.undo_migrate_data
    expect(Legislation::Annotation.all).to be_empty
  end

end
