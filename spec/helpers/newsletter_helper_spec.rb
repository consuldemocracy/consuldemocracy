require "rails_helper"

describe NewsletterHelper do
  describe "#available_actions" do
    context "when the newsletter has not yet been sent" do
      let(:newsletter) { build(:newsletter) }

      it "returns a hash containing an array of default actions" do
        expect(available_actions(newsletter)).to eq({
          actions: [:edit, :destroy]
        })
      end
    end
    context "when the newsletter has already been sent" do
      let(:newsletter) { build(:newsletter, sent_at: Date.today) }

      it "returns a hash containing an array that includes only :destroy action" do
        expect(available_actions(newsletter)).to eq({ actions: [:destroy] })
      end
    end
  end
end
