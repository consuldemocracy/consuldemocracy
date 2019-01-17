require "rails_helper"
require "migrations/legacy_legislation/cleanup"

describe Migrations::LegacyLegislation::Cleanup do

  let(:migration) { Migrations::LegacyLegislation::Cleanup.new }
  let(:info) do
    [
      { id: 1 },
      { id: 2 }
    ]
  end

  before do
    (1..3).each do |n|
      process = create :legislation_process, id: n
      draft_version = create :legislation_draft_version, process: process
      create_list :legislation_annotation, 3, draft_version: draft_version
    end

    3.times do
      process = create :legacy_legislation
      create_list :annotation, 3, legacy_legislation: process
    end

    allow(migration).to receive(:old_processes).and_return(info)
  end

  scenario "Deletes Legislation::Process data only included in old_processes method" do
    expect(Legislation::Process.count).to be 3
    expect(Legislation::DraftVersion.count).to be 3
    expect(Legislation::Annotation.count).to be 9

    migration.delete_old_data

    expect(Legislation::Process.count).to be 1
    expect(Legislation::DraftVersion.count).to be 1
    expect(Legislation::Annotation.count).to be 3

    process = Legislation::Process.first
    expect(process.id).not_to be 1
    expect(process.id).not_to be 2

    draft = process.draft_versions.first
    expect(draft).not_to be nil
    expect(draft.annotations.count).to be 3
  end

  scenario "Deletes all data in table annotations" do
    expect(Annotation.count).to be 9

    migration.delete_old_data

    expect(Annotation.all).to be_empty
  end

  scenario "Deletes all data in table legacy_legislations" do
    expect(LegacyLegislation.count).to be 3

    migration.delete_old_data

    expect(LegacyLegislation.all).to be_empty
  end

end
