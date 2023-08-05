class ApplicationComponent < ViewComponent::Base
  include SettingsHelper

  delegate :back_link_to, :t, :can?, :cannot?, :current_user, :include_html_editor, :invisible_captcha,
           :link_to_add_association, :link_to_remove_association, :page_entries_info, :paginate, to: :helpers
  delegate :default_form_builder, to: :controller
end
