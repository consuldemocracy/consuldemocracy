require "rails_helper"

describe Widget::Feeds::FeedComponent, type: :component do
  it "renders a message when there are no items" do
    feed = double(kind: "debates", items: [])
    component = Widget::Feeds::FeedComponent.new(feed)

    render_inline component

    expect(page).to have_content "no debates"
  end

  describe "#see_all_path" do
    context "debates" do
      let(:feed) { Widget::Feed.new(kind: "debates") }

      it "points to the debates path for homepage debates feeds" do
        component = Widget::Feeds::FeedComponent.new(feed)

        render_inline component

        expect(component.see_all_path).to eq "/debates"
      end

      it "points to the debates filtered by goal for goal feeds" do
        component = Widget::Feeds::FeedComponent.new(SDG::Widget::Feed.new(feed, SDG::Goal[6]))

        render_inline component

        expect(component.see_all_path).to eq "/debates?advanced_search#{CGI.escape("[goal]")}=6"
      end
    end

    context "proposals" do
      let(:feed) { Widget::Feed.new(kind: "proposals") }

      it "points to the proposals path for homepage proposals feeds" do
        component = Widget::Feeds::FeedComponent.new(feed)

        render_inline component

        expect(component.see_all_path).to eq "/proposals"
      end

      it "points to the proposals filtered by goal for goal feeds" do
        component = Widget::Feeds::FeedComponent.new(SDG::Widget::Feed.new(feed, SDG::Goal[6]))

        render_inline component

        expect(component.see_all_path).to eq "/proposals?advanced_search#{CGI.escape("[goal]")}=6"
      end
    end

    context "processes" do
      let(:feed) { Widget::Feed.new(kind: "processes") }

      it "points to the legislation processes path for homepage processes feeds" do
        component = Widget::Feeds::FeedComponent.new(feed)

        render_inline component

        expect(component.see_all_path).to eq "/legislation/processes"
      end

      it "points to the legislation processes path for goal processes feeds" do
        component = Widget::Feeds::FeedComponent.new(SDG::Widget::Feed.new(feed, SDG::Goal[6]))

        render_inline component

        expect(component.see_all_path).to eq "/legislation/processes"
      end
    end
  end
end
