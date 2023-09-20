require "rails_helper"

describe ApplicationComponent do
  it "uses custom translations if present" do
    I18nContent.update([{ id: "shared.yes", values: { "value_en" => "Affirmative" }}])

    component_class = Class.new(ApplicationComponent) do
      def call
        t("shared.yes")
      end

      def self.name
        ""
      end
    end

    render_inline component_class.new

    expect(page).to be_rendered with: "<p>Affirmative</p>"
  end
end
