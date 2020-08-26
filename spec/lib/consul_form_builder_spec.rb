require "rails_helper"

describe ConsulFormBuilder do
  class DummyModel
    include ActiveModel::Model
    attr_accessor :title
  end

  let(:builder) { ConsulFormBuilder.new(:dummy, DummyModel.new, ActionView::Base.new, {}) }

  describe "hints" do
    it "does not generate hints by default" do
      render builder.text_field(:title)

      expect(page).not_to have_css ".help-text"
      expect(page).not_to have_css "input[aria-describedby]"
    end

    it "generates text with a hint if provided" do
      render builder.text_field(:title, hint: "Make it quick")

      expect(page).to have_css ".help-text", text: "Make it quick"
      expect(page).to have_css "input[aria-describedby='dummy_title-help-text']"
    end

    it "does not generate a hint attribute" do
      render builder.text_field(:title)

      expect(page).not_to have_css "input[hint]"
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
