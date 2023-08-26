require "rails_helper"

describe Budgets::Investments::ContentBlocksComponent do
  it "is not rendered without a heading" do
    render_inline Budgets::Investments::ContentBlocksComponent.new(nil)

    expect(page).not_to be_rendered
  end

  it "is not rendered with a heading without custom blocks" do
    heading = Budget::Heading.new(allow_custom_content: true)

    render_inline Budgets::Investments::ContentBlocksComponent.new(heading)

    expect(page).not_to be_rendered
  end

  it "is not rendered with a heading with custom blocks in other languages" do
    heading = create(:budget_heading, allow_custom_content: true)
    create(:heading_content_block, heading: heading, locale: :es)

    render_inline Budgets::Investments::ContentBlocksComponent.new(heading)

    expect(page).not_to be_rendered
  end

  it "is not rendered with a heading not allowing custom content" do
    heading = create(:budget_heading, allow_custom_content: false)
    create(:heading_content_block, heading: heading, locale: :en)

    render_inline Budgets::Investments::ContentBlocksComponent.new(heading)

    expect(page).not_to be_rendered
  end

  it "renders content blocks for the current language" do
    heading = create(:budget_heading, allow_custom_content: true)
    create(:heading_content_block, heading: heading, locale: :en, body: "<li>Heading block</li>")

    render_inline Budgets::Investments::ContentBlocksComponent.new(heading)

    page.find("ul") do |list|
      expect(page).to have_css "li", exact_text: "Heading block"
    end
  end
end
