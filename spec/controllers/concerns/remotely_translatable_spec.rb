require "rails_helper"
include RemotelyTranslatable

describe RemotelyTranslatable do

  before do
    Setting["feature.remote_translations"] = true
  end

  after do
    Setting["feature.remote_translations"] = nil
  end

  describe "#detect_remote_translations" do

    describe "Should detect remote_translations" do

      it "When collections and featured_proposals are not defined in current locale" do
        proposals = create_list(:proposal, 3)
        featured_proposals = create_featured_proposals

        I18n.with_locale(:es) do
          expect(detect_remote_translations(proposals, featured_proposals).count).to eq 6
        end
      end

      it "When we have nil as argument and collections are not defined in current locale" do
        proposals = create_list(:proposal, 3)

        I18n.with_locale(:es) do
          expect(detect_remote_translations(proposals, nil).count).to eq 3
        end
      end

      it "When we have [] as argument and collections are not defined in current locale" do
        proposals = create_list(:proposal, 3)

        I18n.with_locale(:es) do
          expect(detect_remote_translations(proposals, []).count).to eq 3
        end
      end

      it "When widget feeds are not defined in current locale" do
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

    end

    it "When defined in current locale should not detect remote_translations" do
      proposal = create(:proposal)
      comment = create(:comment, commentable: proposal)

      expect(detect_remote_translations([proposal, comment])).to eq []
    end
  end
end
