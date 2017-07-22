require "rails_helper"

RSpec.describe "welcome/index" do

  it 'Display images on orbit carrousel when we have defined image_default' do
    debate = create(:debate)

    render template: "welcome/_recommended_carousel.html.erb",
           locals: { key: "debates",
                     recommendeds: [debate],
                     image_field: nil,
                     image_version: nil,
                     image_default: "https://dummyimage.com/600x400/000/fff"}

    within 'li[data-slide="0"] .card' do
      expect(page).to have_selector("img")
    end

  end

  it 'Not display images on orbit carrousel when we have not defined image_default' do
    debate = create(:debate)

    render template: "welcome/_recommended_carousel.html.erb",
           locals: { key: "debates",
                     recommendeds: [debate],
                     image_field: nil,
                     image_version: nil,
                     image_default: nil}

    within 'li[data-slide="0"] .card' do
      expect(page).not_to have_selector("img")
    end

  end

end
