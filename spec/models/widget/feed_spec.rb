require "rails_helper"

describe Widget::Feed do
  let(:feed) { build(:widget_feed) }

  context "validations" do
    it "is valid" do
      expect(feed).to be_valid
    end
  end

  context "kinds" do
    describe "#proposals" do
      it "returns the most active proposals" do
        best_proposal = create(:proposal, title: "Best proposal")
        best_proposal.update_column(:hot_score, 10)

        worst_proposal = create(:proposal, title: "Worst proposal")
        worst_proposal.update_column(:hot_score, 2)

        even_worst_proposal = create(:proposal, title: "Worst proposal")
        even_worst_proposal.update_column(:hot_score, 1)

        medium_proposal = create(:proposal, title: "Medium proposal")
        medium_proposal.update_column(:hot_score, 5)

        feed = build(:widget_feed, kind: "proposals")

        expect(feed.proposals).to eq([best_proposal, medium_proposal, worst_proposal])
      end

      it "does not return unpublished proposals" do
        create(:proposal, :draft, title: "Draft proposal")

        feed = build(:widget_feed, kind: "proposals")

        expect(feed.proposals).to be_empty
      end
    end

    describe "#debates" do
      it "returns the most active debates" do
        best_debate = create(:debate, title: "Best debate")
        best_debate.update_column(:hot_score, 10)

        worst_debate = create(:debate, title: "Worst debate")
        worst_debate.update_column(:hot_score, 2)

        even_worst_debate = create(:debate, title: "Worst debate")
        even_worst_debate.update_column(:hot_score, 1)

        medium_debate = create(:debate, title: "Medium debate")
        medium_debate.update_column(:hot_score, 5)

        feed = build(:widget_feed, kind: "debates")

        expect(feed.debates).to eq([best_debate, medium_debate, worst_debate])
      end
    end

    describe "#processes" do
      let(:feed) {  build(:widget_feed, kind: "processes", limit: 3) }

      it "returns a maximum number of open published processes given by the limit" do
        4.times { create(:legislation_process, :open, :published) }

        expect(feed.processes.count).to be 3
      end

      it "does not return past processes" do
        create(:legislation_process, :past)

        expect(feed.processes).to be_empty
      end

      it "does not return unpublished processes" do
        create(:legislation_process, :open, :not_published)

        expect(feed.processes).to be_empty
      end
    end
  end
end
