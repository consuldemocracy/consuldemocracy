require "rails_helper"

describe LinkListHelper do
  describe "#link_list" do
    it "returns an empty string with an empty list" do
      expect(helper.link_list).to eq ""
    end

    it "returns nothing with a list of nil elements" do
      expect(helper.link_list(nil, nil)).to eq ""
    end

    it "generates a list of links" do
      list = helper.link_list(["Home", "/"], ["Info", "/info"], class: "menu")

      expect(list).to eq '<ul class="menu"><li><a href="/">Home</a></li><li><a href="/info">Info</a></li></ul>'
      expect(list).to be_html_safe
    end

    it "accepts options for links" do
      render helper.link_list(["Home", "/", class: "root"], ["Info", "/info", id: "info"])

      expect(page).to have_css "a", count: 2
      expect(page).to have_css "a.root", count: 1, exact_text: "Home"
      expect(page).to have_css "a#info", count: 1, exact_text: "Info"
    end

    it "ignores nil entries" do
      render helper.link_list(["Home", "/", class: "root"], nil, ["Info", "/info", id: "info"])

      expect(page).to have_css "a", count: 2
      expect(page).to have_css "a.root", count: 1, exact_text: "Home"
      expect(page).to have_css "a#info", count: 1, exact_text: "Info"
    end
  end

  attr_reader :content

  def render(content)
    @content = content
  end

  def page
    Capybara::Node::Simple.new(content)
  end
end
