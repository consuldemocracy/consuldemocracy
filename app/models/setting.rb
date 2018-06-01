class Setting < ActiveRecord::Base
  validates :key, presence: true, uniqueness: true

  default_scope { order(id: :asc) }
  scope :banner_style, -> { where("key ilike ?", "banner-style.%")}
  scope :banner_img, -> { where("key ilike ?", "banner-img.%")}

  def type
    if feature_flag?
      'feature'
    elsif banner_style?
      'banner-style'
    elsif banner_img?
      'banner-img'
    else
      'common'
    end
  end

  def feature_flag?
    key.start_with?('feature.')
  end

  def enabled?
    feature_flag? && value.present?
  end

  def banner_style?
    key.start_with?('banner-style.')
  end

  def banner_img?
    key.start_with?('banner-img.')
  end

  class << self
    def [](key)
      where(key: key).pluck(:value).first.presence
    end

    def []=(key, value)
      setting = where(key: key).first || new(key: key)
      setting.value = value.presence
      setting.save!
      value
    end
  end
end
