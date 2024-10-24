require "rails_helper"

describe TranslatableFormBuilder do
  before do
    dummy_banner = Class.new(ApplicationRecord) do
      def self.name
        "DummyBanner"
      end
      self.table_name = "banners"

      translates :title, touch: true
      include Globalizable
      has_many :translations, class_name: "DummyBanner::Translation", foreign_key: "banner_id"
    end

    stub_const("DummyBanner", dummy_banner)
  end

  let(:builder) do
    TranslatableFormBuilder.new(:dummy, DummyBanner.new, ApplicationController.new.view_context, {})
  end

  describe "#translatable_fields" do
    it "renders fields for the enabled locales when the translation interface is enabled" do
      Setting["feature.translation_interface"] = true
      Setting["locales.enabled"] = "en fr"

      builder.translatable_fields do |translations_builder|
        render translations_builder.text_field :title
      end

      expect(page).to have_field "Title", count: 2
    end
  end

  attr_reader :content

  def render(content)
    @content ||= ""
    @content << content
  end

  def page
    Capybara::Node::Simple.new(content)
  end
end
