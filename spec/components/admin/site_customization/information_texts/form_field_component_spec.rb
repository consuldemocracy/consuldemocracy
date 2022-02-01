require "rails_helper"

describe Admin::SiteCustomization::InformationTexts::FormFieldComponent do
  after { I18n.backend.reload! }

  it "uses the I18n translation when the record exists without a database translation" do
    I18n.backend.store_translations(:en, { testing: "It works!" })
    content = I18nContent.create!(key: "testing")

    render_inline Admin::SiteCustomization::InformationTexts::FormFieldComponent.new(content, locale: :en)

    expect(page).to have_field with: "It works!"
  end
end
