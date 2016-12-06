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

    it "filter open" do
      open_processes = ::Legislation::Process.open

      expect(open_processes).to include(@process_1)
      expect(open_processes).to_not include(@process_2)
      expect(open_processes).to_not include(@process_3)
    end

    it "filter next" do
      next_processes = ::Legislation::Process.next

      expect(next_processes).to include(@process_2)
      expect(next_processes).to_not include(@process_1)
      expect(next_processes).to_not include(@process_3)
    end

    it "filter past" do
      past_processes = ::Legislation::Process.past

      expect(past_processes).to include(@process_3)
      expect(past_processes).to_not include(@process_2)
      expect(past_processes).to_not include(@process_1)
    end
  end
end
