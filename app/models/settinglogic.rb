class Setting < Settingslogic
  source "#{Rails.root}/config/application.yml"
  namespace Rails.env

  class << self
    delegate :value_for, to: :[]
  end
end
