require 'rails_helper'

RSpec.describe SiteCustomization::Page, type: :model do
  let(:custom_page) { build(:site_customization_page) }

  it "is valid" do
    expect(custom_page).to be_valid
  end

  it "is invalid if slug has symbols" do
    custom_page = build(:site_customization_page, slug: "as/as*la")
    expect(custom_page).to be_invalid
  end
end

# == Schema Information
#
# Table name: site_customization_pages
#
#  id                 :integer          not null, primary key
#  slug               :string           not null
#  title              :string           not null
#  subtitle           :string
#  content            :text
#  more_info_flag     :boolean
#  print_content_flag :boolean
#  status             :string           default("draft")
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  locale             :string
#
