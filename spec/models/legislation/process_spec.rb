require 'rails_helper'

RSpec.describe Legislation::Process, type: :model do
  let(:legislation_process) { build(:legislation_process) }

  it "should be valid" do
    expect(legislation_process).to be_valid
  end

  describe "filter scopes" do
    before(:each) do
      @process_1 = create(:legislation_process, start_date: Date.current - 2.days, end_date: Date.current + 1.day)
      @process_2 = create(:legislation_process, start_date: Date.current + 1.days, end_date: Date.current + 3.days)
      @process_3 = create(:legislation_process, start_date: Date.current - 4.days, end_date: Date.current - 3.days)
    end

    it "filters open" do
      open_processes = ::Legislation::Process.open

      expect(open_processes).to include(@process_1)
      expect(open_processes).to_not include(@process_2)
      expect(open_processes).to_not include(@process_3)
    end

    it "filters next" do
      next_processes = ::Legislation::Process.next

      expect(next_processes).to include(@process_2)
      expect(next_processes).to_not include(@process_1)
      expect(next_processes).to_not include(@process_3)
    end

    it "filters past" do
      past_processes = ::Legislation::Process.past

      expect(past_processes).to include(@process_3)
      expect(past_processes).to_not include(@process_2)
      expect(past_processes).to_not include(@process_1)
    end
  end

  describe "#open_phase?" do
    it "checks debate phase" do
      process = create(:legislation_process)

      # future
      process.update_attributes(debate_start_date: Date.current + 2.days, debate_end_date: Date.current + 3.days)
      expect(process.open_phase?(:debate)).to be false

      # started
      process.update_attributes(debate_start_date: Date.current - 2.days, debate_end_date: Date.current + 1.day)
      expect(process.open_phase?(:debate)).to be true

      # starts today
      process.update_attributes(debate_start_date: Date.current, debate_end_date: Date.current + 1.day)
      expect(process.open_phase?(:debate)).to be true

      # past
      process.update_attributes(debate_start_date: Date.current - 2.days, debate_end_date: Date.current - 1.day)
      expect(process.open_phase?(:debate)).to be false
    end

    it "checks allegations phase" do
      process = create(:legislation_process)

      # future
      process.update_attributes(allegations_start_date: Date.current + 2.days, allegations_end_date: Date.current + 3.days)
      expect(process.open_phase?(:allegations)).to be false

      # started
      process.update_attributes(allegations_start_date: Date.current - 2.days, allegations_end_date: Date.current + 1.day)
      expect(process.open_phase?(:allegations)).to be true

      # starts today
      process.update_attributes(allegations_start_date: Date.current, allegations_end_date: Date.current + 1.day)
      expect(process.open_phase?(:allegations)).to be true

      # past
      process.update_attributes(allegations_start_date: Date.current - 2.days, allegations_end_date: Date.current - 1.day)
      expect(process.open_phase?(:allegations)).to be false
    end

    it "checks draft publication phase" do
      process = create(:legislation_process)

      # future
      process.update_attributes(draft_publication_date: Date.current + 2.days)
      expect(process.open_phase?(:draft_publication)).to be false

      # past
      process.update_attributes(draft_publication_date: Date.current - 2.days)
      expect(process.open_phase?(:draft_publication)).to be true

      # starts today
      process.update_attributes(draft_publication_date: Date.current)
      expect(process.open_phase?(:draft_publication)).to be true
    end

    it "checks final version publication phase" do
      process = create(:legislation_process)

      # future
      process.update_attributes(final_publication_date: Date.current + 2.days)
      expect(process.open_phase?(:final_version_publication)).to be false

      # past
      process.update_attributes(final_publication_date: Date.current - 2.days)
      expect(process.open_phase?(:final_version_publication)).to be true

      # starts today
      process.update_attributes(final_publication_date: Date.current)
      expect(process.open_phase?(:final_version_publication)).to be true
    end
  end

  describe "#show_phase?" do
    it "checks debate phase" do
      process = create(:legislation_process)

      # future
      process.update_attributes(debate_start_date: Date.current + 2.days, debate_end_date: Date.current + 3.days)
      expect(process.show_phase?(:debate)).to be false

      # started
      process.update_attributes(debate_start_date: Date.current - 2.days, debate_end_date: Date.current + 1.day)
      expect(process.show_phase?(:debate)).to be true

      # starts today
      process.update_attributes(debate_start_date: Date.current, debate_end_date: Date.current + 1.day)
      expect(process.show_phase?(:debate)).to be true

      # past
      process.update_attributes(debate_start_date: Date.current - 2.days, debate_end_date: Date.current - 1.day)
      expect(process.show_phase?(:debate)).to be true
    end

    it "checks allegations phase" do
      process = create(:legislation_process)

      # future
      process.update_attributes(allegations_start_date: Date.current + 2.days, allegations_end_date: Date.current + 3.days)
      expect(process.show_phase?(:allegations)).to be false

      # started
      process.update_attributes(allegations_start_date: Date.current - 2.days, allegations_end_date: Date.current + 1.day)
      expect(process.show_phase?(:allegations)).to be true

      # starts today
      process.update_attributes(allegations_start_date: Date.current, allegations_end_date: Date.current + 1.day)
      expect(process.show_phase?(:allegations)).to be true

      # past
      process.update_attributes(allegations_start_date: Date.current - 2.days, allegations_end_date: Date.current - 1.day)
      expect(process.show_phase?(:allegations)).to be true
    end

    it "checks draft publication phase" do
      process = create(:legislation_process)

      # future
      process.update_attributes(draft_publication_date: Date.current + 2.days)
      expect(process.show_phase?(:draft_publication)).to be false

      # past
      process.update_attributes(draft_publication_date: Date.current - 2.days)
      expect(process.show_phase?(:draft_publication)).to be true

      # starts today
      process.update_attributes(draft_publication_date: Date.current)
      expect(process.show_phase?(:draft_publication)).to be true
    end

    it "checks final version publication phase" do
      process = create(:legislation_process)

      # future
      process.update_attributes(final_publication_date: Date.current + 2.days)
      expect(process.show_phase?(:final_version_publication)).to be false

      # past
      process.update_attributes(final_publication_date: Date.current - 2.days)
      expect(process.show_phase?(:final_version_publication)).to be true

      # starts today
      process.update_attributes(final_publication_date: Date.current)
      expect(process.show_phase?(:final_version_publication)).to be true
    end
  end
end
