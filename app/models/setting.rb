class Setting < ActiveRecord::Base
  validates :key, presence: true, uniqueness: true

  default_scope { order(id: :asc) }

  class << self
    def [](key)
      where(key: key).pluck(:value).first
    end

    def []=(key, value)
      setting = where(key: key).first || new(key: key)
      setting.value = value
      setting.value = nil if setting.value == false
      setting.save!
      value
    end
  end
end
