class Admin::Settings::RowComponent < ApplicationComponent
  attr_reader :key, :tab, :type, :options, :disabled
  delegate :dom_id, to: :helpers

  def initialize(key, type: :text, tab: nil, options: nil, disabled: false)
    @key = key
    @type = type
    @tab = tab
    @options = options
    @disabled = disabled
  end

  def setting
    @setting ||= Setting.find_by!(key: key)
  end

  def content_type_setting?
    type == :content_type
  end

  def featured_setting?
    type == :feature
  end

  def dropdown_setting?
    type == :dropdown
  end
end
