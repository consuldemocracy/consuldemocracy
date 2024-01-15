FactoryBot.define do
  factory :setting do
    sequence(:key) { |n| "Setting Key #{n}" }
    sequence(:value) { |n| "Setting #{n} Value" }
  end

  factory :geozone do
    sequence(:name) { |n| "District #{n}" }
    sequence(:external_code, &:to_s)
    sequence(:census_code, &:to_s)
    color { "#0081aa" }

    trait :in_census do
      census_code { "01" }
    end

    trait :with_html_coordinates do
      html_map_coordinates { "30,139,45,153,77,148,107,165" }
    end

    trait :with_geojson do
      geojson { '{ "geometry": { "type": "Polygon", "coordinates": [[-0.117,51.513],[-0.118,51.512],[-0.119,51.514]] } }' }
    end
  end

  factory :banner do
    sequence(:title) { |n| "Banner title #{n}" }
    sequence(:description) { |n| "This is the text of Banner #{n}" }
    target_url { ["/proposals", "/debates"].sample }
    post_started_at { Date.current - 7.days }
    post_ended_at { Date.current + 7.days }
    background_color { "#FF0000" }
    font_color { "#FFFFFF" }
  end

  factory :web_section do
    name { "homepage" }
  end

  factory :banner_section, class: "Banner::Section" do
    association :banner_id, factory: :banner
    association :web_section, factory: :web_section
  end

  factory :site_customization_page, class: "SiteCustomization::Page" do
    slug { "example-page" }
    title { "Example page" }
    subtitle { "About an example" }
    content { "This page is about..." }
    more_info_flag { false }
    print_content_flag { false }
    status { "draft" }

    trait :published do
      status { "published" }
    end

    trait :display_in_more_info do
      more_info_flag { true }
    end
  end

  factory :site_customization_content_block, class: "SiteCustomization::ContentBlock" do
    name { "top_links" }
    locale { "en" }
    body { "Some top links content" }
  end

  factory :site_customization_image, class: "SiteCustomization::Image" do
    image { Rack::Test::UploadedFile.new("spec/fixtures/files/logo_header.png") }
    name { "logo_header" }
  end

  factory :map_location do
    latitude { 51.48 }
    longitude { 0.0 }
    zoom { 10 }

    trait :proposal_map_location do
      proposal
    end

    trait :budget_investment_map_location do
      association :investment, factory: :budget_investment
    end
  end

  factory :widget_card, class: "Widget::Card" do
    sequence(:title)       { |n| "Title #{n}" }
    sequence(:description) { |n| "Description #{n}" }
    sequence(:link_text)   { |n| "Link text #{n}" }
    sequence(:link_url)    { |n| "Link url #{n}" }

    trait :header do
      header { true }
    end

    after :create do |widget_card|
      create(:image, imageable: widget_card)
    end
  end

  factory :widget_feed, class: "Widget::Feed"

  factory :i18n_content, class: "I18nContent" do
    key { "debates.index.section_footer.description" }
    value_es { "Texto en español" }
    value_en { "Text in english" }
  end

  factory :tenant do
    sequence(:name) { |n| "Tenant #{n}" }
    sequence(:schema) { |n| "subdomain#{n}" }

    trait :domain do
      schema_type { :domain }
    end
  end
end
