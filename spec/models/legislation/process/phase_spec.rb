require "rails_helper"

RSpec.describe Legislation::Process::Phase, type: :model do
  let(:process) { create(:legislation_process) }
  let(:process_in_draft_phase) { create(:legislation_process, :in_draft_phase) }

  describe "#enabled?" do
    it "checks debate phase" do
      expect(process.debate_phase.enabled?).to be true

      process.update_attributes(debate_phase_enabled: false)
      expect(process.debate_phase.enabled?).to be false
    end

    it "checks draft phase" do
      expect(process.draft_phase.enabled?).to be false
      expect(process_in_draft_phase.draft_phase.enabled?).to be true

      process.update_attributes(draft_phase_enabled: false)
      expect(process.draft_phase.enabled?).to be false
    end


    it "checks allegations phase" do
      expect(process.allegations_phase.enabled?).to be true

      process.update_attributes(allegations_phase_enabled: false)
      expect(process.allegations_phase.enabled?).to be false
    end
  end

  describe "#started?" do
    it "checks debate phase" do
      # future
      process.update_attributes(debate_start_date: Date.current + 2.days,
                                debate_end_date: Date.current + 3.days)
      expect(process.debate_phase.started?).to be false

      # started
      process.update_attributes(debate_start_date: Date.current - 2.days,
                                debate_end_date: Date.current + 1.day)
      expect(process.debate_phase.started?).to be true

      # starts today
      process.update_attributes(debate_start_date: Date.current,
                                debate_end_date: Date.current + 1.day)
      expect(process.debate_phase.started?).to be true

      # past
      process.update_attributes(debate_start_date: Date.current - 2.days,
                                debate_end_date: Date.current - 1.day)
      expect(process.debate_phase.started?).to be true
    end

    it "checks draft phase" do
      # future
      process.update_attributes(draft_start_date: Date.current + 2.days,
                                draft_end_date: Date.current + 3.days, draft_phase_enabled: true)
      expect(process.draft_phase.started?).to be false

      # started
      process.update_attributes(draft_start_date: Date.current - 2.days,
                                draft_end_date: Date.current + 1.day, draft_phase_enabled: true)
      expect(process.draft_phase.started?).to be true

      # starts today
      process.update_attributes(draft_start_date: Date.current,
                                draft_end_date: Date.current + 1.day, draft_phase_enabled: true)
      expect(process.draft_phase.started?).to be true

      # past
      process.update_attributes(draft_start_date: Date.current - 2.days,
                                draft_end_date: Date.current - 1.day, draft_phase_enabled: true)
      expect(process.draft_phase.started?).to be true
    end

    it "checks allegations phase" do
      # future
      process.update_attributes(allegations_start_date: Date.current + 2.days,
                                allegations_end_date: Date.current + 3.days)
      expect(process.allegations_phase.started?).to be false

      # started
      process.update_attributes(allegations_start_date: Date.current - 2.days,
                                allegations_end_date: Date.current + 1.day)
      expect(process.allegations_phase.started?).to be true

      # starts today
      process.update_attributes(allegations_start_date: Date.current,
                                allegations_end_date: Date.current + 1.day)
      expect(process.allegations_phase.started?).to be true

      # past
      process.update_attributes(allegations_start_date: Date.current - 2.days,
                                allegations_end_date: Date.current - 1.day)
      expect(process.allegations_phase.started?).to be true
    end
  end

  describe "#open?" do
    it "checks debate phase" do
      # future
      process.update_attributes(debate_start_date: Date.current + 2.days,
                                debate_end_date: Date.current + 3.days)
      expect(process.debate_phase.open?).to be false

      # started
      process.update_attributes(debate_start_date: Date.current - 2.days,
                                debate_end_date: Date.current + 1.day)
      expect(process.debate_phase.open?).to be true

      # starts today
      process.update_attributes(debate_start_date: Date.current,
                                debate_end_date: Date.current + 1.day)
      expect(process.debate_phase.open?).to be true

      # past
      process.update_attributes(debate_start_date: Date.current - 2.days,
                                debate_end_date: Date.current - 1.day)
      expect(process.debate_phase.open?).to be false
    end

    it "checks draft phase" do
      # future
      process.update_attributes(draft_start_date: Date.current + 2.days,
                                draft_end_date: Date.current + 3.days, draft_phase_enabled: true)
      expect(process.draft_phase.open?).to be false

      # started
      process.update_attributes(draft_start_date: Date.current - 2.days,
                                draft_end_date: Date.current + 1.day, draft_phase_enabled: true)
      expect(process.draft_phase.open?).to be true

      # starts today
      process.update_attributes(draft_start_date: Date.current,
                                draft_end_date: Date.current + 1.day, draft_phase_enabled: true)
      expect(process.draft_phase.open?).to be true

      # past
      process.update_attributes(draft_start_date: Date.current - 2.days,
                                draft_end_date: Date.current - 1.day, draft_phase_enabled: true)
      expect(process.draft_phase.open?).to be false
    end

    it "checks allegations phase" do

      # future
      process.update_attributes(allegations_start_date: Date.current + 2.days,
                                allegations_end_date: Date.current + 3.days)
      expect(process.allegations_phase.open?).to be false

      # started
      process.update_attributes(allegations_start_date: Date.current - 2.days,
                                allegations_end_date: Date.current + 1.day)
      expect(process.allegations_phase.open?).to be true

      # starts today
      process.update_attributes(allegations_start_date: Date.current,
                                allegations_end_date: Date.current + 1.day)
      expect(process.allegations_phase.open?).to be true

      # past
      process.update_attributes(allegations_start_date: Date.current - 2.days,
                                allegations_end_date: Date.current - 1.day)
      expect(process.allegations_phase.open?).to be false
    end
  end

end
