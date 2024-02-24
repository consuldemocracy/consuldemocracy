class Admin::Settings::RowComponent < ApplicationComponent
  attr_reader :key, :tab, :type
  delegate :dom_id, to: :helpers

  def initialize(key, type: :text, tab: nil)
    @key = key
    @type = type
    @tab = tab
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
end
