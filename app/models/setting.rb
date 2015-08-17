class Setting < ActiveRecord::Base
  default_scope { order(key: :desc) }

  def self.value_for(key)
    where(key: key).pluck(:value).first
  end
end