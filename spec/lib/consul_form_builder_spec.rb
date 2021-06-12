require "rails_helper"

describe ConsulFormBuilder do
  before do
    dummy_model = Class.new do
      include ActiveModel::Model
      attr_accessor :title, :quality
    end

    stub_const("DummyModel", dummy_model)
    stub_const("DummyModel::OPTIONS", %w[Good Bad Ugly].freeze)
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

  describe "#select" do
    it "renders the label and the select with the given options" do
      render builder.select(:quality, DummyModel::OPTIONS)

      expect(page).to have_css "label", count: 1
      expect(page).to have_css "label", text: "Quality"
      expect(page).to have_css "select", count: 1
      expect(page).to have_css "option", count: 3
      expect(page).to have_css "option", text: "Good"
      expect(page).to have_css "option", text: "Bad"
      expect(page).to have_css "option", text: "Ugly"
    end

    it "accepts hints" do
      render builder.select(:quality, DummyModel::OPTIONS, hint: "Ugly is neither good nor bad")

      expect(page).to have_css ".help-text", text: "Ugly is neither good nor bad"
      expect(page).to have_css "select[aria-describedby='dummy_quality-help-text']"
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
