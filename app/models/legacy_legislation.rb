class LegacyLegislation < ActiveRecord::Base
  has_many :annotations
end

# == Schema Information
#
# Table name: legacy_legislations
#
#  id         :integer          not null, primary key
#  title      :string
#  body       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
