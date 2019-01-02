require 'rails_helper'
require 'migrations/legacy_legislation/process'

describe Migrations::LegacyLegislation::Process do

  let(:user)        { create(:user) }
  let(:draft)       { "<p>Draft information</p>" }
  let(:description) { "<p>Description information</p>" }
  let(:additional)  { "<p>Additional information</p>" }
  let(:draft_path)       { Rails.root.join("draft_file") }
  let(:description_path) { Rails.root.join("description_file") }
  let(:additional_path)  { Rails.root.join("additional_file") }
  let(:document_path)    { Rails.root.join("spec/fixtures/files/logo.pdf") }
  let(:info) do
    [
      {
        start_date: "01/01/2018",
        end_date: "31/12/2018",
        title: "Process Title",
        draft_file: "draft_file",
        documents: []
      }
    ]
  end

  before do
    allow(File).to receive(:exists?).with(draft_path).and_return true
    allow(File).to receive(:read).with(draft_path).and_return draft
  end

  scenario "Migrate a process without documents, description and additional info" do
    migration = Migrations::LegacyLegislation::Process.new
    allow(migration).to receive(:old_processes_info).and_return(info)

    migration.migrate_processes

    expect(Legislation::Process.count).to be 1
    process = Legislation::Process.first
    expect(process.title).to eq "Process Title"
    expect(process.description).to be nil
    expect(process.additional_info).to be nil
  end

  scenario "Migrate a process with description and additional info" do
    info.first[:description_file] = "description_file"
    info.first[:additional_file] = "additional_file"

    migration = Migrations::LegacyLegislation::Process.new
    allow(migration).to receive(:old_processes_info).and_return(info)
    allow(File).to receive(:exists?).with(description_path).and_return true
    allow(File).to receive(:exists?).with(additional_path).and_return true
    allow(File).to receive(:read).with(description_path).and_return description
    allow(File).to receive(:read).with(additional_path).and_return additional

    migration.migrate_processes

    expect(Legislation::Process.count).to be 1
    process = Legislation::Process.first
    expect(process.title).to eq "Process Title"
    expect(process.description).to eq "<p>Description information</p>"
    expect(process.additional_info).to eq "<p>Additional information</p>"
  end

  scenario "Migrate a process with description, additional info and documents" do
    info.first[:description_file] = "description_file"
    info.first[:additional_file] = "additional_file"
    info.first[:documents] << {title: "Document Title", path: document_path}

    user.update_columns id: 1

    migration = Migrations::LegacyLegislation::Process.new
    allow(migration).to receive(:old_processes_info).and_return(info)
    allow(File).to receive(:exists?).with(description_path).and_return true
    allow(File).to receive(:exists?).with(additional_path).and_return true
    allow(File).to receive(:exists?).with(document_path).and_return true
    allow(File).to receive(:read).with(description_path).and_return description
    allow(File).to receive(:read).with(additional_path).and_return additional

    migration.migrate_processes

    expect(Legislation::Process.count).to be 1
    process = Legislation::Process.first
    expect(process.title).to eq "Process Title"
    expect(process.description).to eq "<p>Description information</p>"
    expect(process.additional_info).to eq "<p>Additional information</p>"
    expect(process.start_date).to eq "01/01/2018".to_date
    expect(process.end_date).to eq "31/12/2018".to_date
    expect(process.draft_publication_date).to eq "01/01/2018".to_date
    expect(process.allegations_start_date).to eq "01/01/2018".to_date
    expect(process.allegations_end_date).to eq "31/12/2018".to_date
    expect(process.created_at).to eq "01/01/2018".to_time
    expect(process.updated_at).to eq "01/01/2018".to_time
    expect(process.draft_publication_enabled).to be true
    expect(process.allegations_phase_enabled).to be true
    expect(process.published).to be true

    expect(process.draft_versions.count).to be 1
    draft_version = process.draft_versions.first
    expect(draft_version.title).to eq "borrador"
    expect(draft_version.body).to eq "<p>Draft information</p>"
    expect(draft_version.body_html).to eq "<p>Draft information</p>\n"
    expect(draft_version.created_at).to eq "01/01/2018".to_time
    expect(draft_version.updated_at).to eq "01/01/2018".to_time
    expect(draft_version.status).to eq "published"

    expect(process.documents.count).to be 1
    doc = process.documents.first
    expect(doc.title).to eq "Document Title"
    expect(doc.user_id).to be 1
  end

end
