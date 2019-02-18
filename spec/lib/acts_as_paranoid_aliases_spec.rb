require "rails_helper"

describe "Paranoid methods" do

  describe ".hide_all" do
    it "hides all instances in the id list" do
      debate1 = create(:debate)
      debate2 = create(:debate)
      debate3 = create(:debate)
      debate4 = create(:debate)

      expect(Debate.all.sort).to eq([debate1, debate2, debate3, debate4].sort)

      Debate.hide_all [debate1, debate2, debate4].map(&:id)

      expect(Debate.all).to eq([debate3])
    end
  end

  describe ".restore_all" do
    it "restores all instances in the id list" do
      debate1 = create(:debate)
      debate2 = create(:debate)
      debate3 = create(:debate)

      debate1.hide
      debate3.hide

      expect(Debate.all).to eq([debate2])

      Debate.restore_all [debate1, debate3].map(&:id)

      expect(Debate.all.sort).to eq([debate1, debate2, debate3].sort)
    end
  end

  describe "#restore" do
    it "resets the confirmed_hide_at attribute" do
      debate = create(:debate, :hidden, :with_confirmed_hide)

      debate.restore

      expect(debate.reload.confirmed_hide?).not_to be
    end
  end

end
