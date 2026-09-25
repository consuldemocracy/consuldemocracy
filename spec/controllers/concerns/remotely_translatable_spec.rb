require "rails_helper"
include RemotelyTranslatable

describe RemotelyTranslatable do
  before do
    allow(RemoteTranslations::Caller).to receive(:configured?).and_return(true)
  end

  describe "#detect_remote_translations" do
    it "detects remote translations when collections and featured_proposals are not translated" do
      proposals = create_list(:proposal, 3)
      featured_proposals = create_featured_proposals

      I18n.with_locale(:es) do
        expect(detect_remote_translations(proposals, featured_proposals).count).to eq 6
      end
    end

    it "detects remote translations with nil as argument when collections are not translated" do
      proposals = create_list(:proposal, 3)

      I18n.with_locale(:es) do
        expect(detect_remote_translations(proposals, nil).count).to eq 3
      end
    end

    it "detects remote translations with [] as argument when collections are not translated" do
      proposals = create_list(:proposal, 3)

      I18n.with_locale(:es) do
        expect(detect_remote_translations(proposals, []).count).to eq 3
      end
    end

    it "detects remote translations when widget feeds are not translated" do
      create_list(:proposal, 3)
      create_list(:debate, 3)
      create_list(:legislation_process, 3)
      create(:widget_feed, kind: "proposals")
      create(:widget_feed, kind: "debates")
      create(:widget_feed, kind: "processes")
      widget_feeds = Widget::Feed.active

      I18n.with_locale(:es) do
        expect(detect_remote_translations(widget_feeds).count).to eq 9
      end
    end

    it "does not detect remote translations when they aren't configured" do
      allow(RemoteTranslations::Caller).to receive(:configured?).and_return(false)
      proposal = create(:proposal)
      comment = create(:comment, commentable: proposal)

      I18n.with_locale(:es) do
        expect(detect_remote_translations([proposal, comment])).to eq []
      end
    end

    it "does not detect remote translations when collections are already translated" do
      proposal = create(:proposal)
      comment = create(:comment, commentable: proposal)

      expect(detect_remote_translations([proposal, comment])).to eq []
    end

    it "does not detect remote translations when the resource class is not translatable" do
      legislation_proposal = create(:legislation_proposal)

      I18n.with_locale(:es) do
        expect(detect_remote_translations([legislation_proposal])).to eq []
      end
    end
  end
end
