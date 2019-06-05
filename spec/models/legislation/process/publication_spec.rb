require "rails_helper"

RSpec.describe Legislation::Process::Publication, type: :model do
  let(:process) { create(:legislation_process) }

  describe "#enabled?" do
    it "checks draft publication" do
      expect(process.draft_publication.enabled?).to be true

      process.update_attributes(draft_publication_enabled: false)
      expect(process.draft_publication.enabled?).to be false
    end

    it "checks result publication" do
      expect(process.result_publication.enabled?).to be true

      process.update_attributes(result_publication_enabled: false)
      expect(process.result_publication.enabled?).to be false
    end
  end

  describe "#started?" do
    it "checks draft publication" do
      # future
      process.update_attributes(draft_publication_date: Date.current + 2.days)
      expect(process.draft_publication.started?).to be false

      # past
      process.update_attributes(draft_publication_date: Date.current - 2.days)
      expect(process.draft_publication.started?).to be true

      # starts today
      process.update_attributes(draft_publication_date: Date.current)
      expect(process.draft_publication.started?).to be true
    end

    it "checks result publication" do
      # future
      process.update_attributes(result_publication_date: Date.current + 2.days)
      expect(process.result_publication.started?).to be false

      # past
      process.update_attributes(result_publication_date: Date.current - 2.days)
      expect(process.result_publication.started?).to be true

      # starts today
      process.update_attributes(result_publication_date: Date.current)
      expect(process.result_publication.started?).to be true
    end
  end

  describe "#open?" do
    it "checks draft publication" do
      # future
      process.update_attributes(draft_publication_date: Date.current + 2.days)
      expect(process.draft_publication.open?).to be false

      # past
      process.update_attributes(draft_publication_date: Date.current - 2.days)
      expect(process.draft_publication.open?).to be true

      # starts today
      process.update_attributes(draft_publication_date: Date.current)
      expect(process.draft_publication.open?).to be true
    end

    it "checks result publication" do
      # future
      process.update_attributes(result_publication_date: Date.current + 2.days)
      expect(process.result_publication.open?).to be false

      # past
      process.update_attributes(result_publication_date: Date.current - 2.days)
      expect(process.result_publication.open?).to be true

      # starts today
      process.update_attributes(result_publication_date: Date.current)
      expect(process.result_publication.open?).to be true
    end
  end
end
