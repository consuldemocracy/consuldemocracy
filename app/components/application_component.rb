class ApplicationComponent < ViewComponent::Base
  include SettingsHelper
  include ActionView::Helpers::TranslationHelper

  def t(key = nil, **options)
    ActionView::Helpers::TranslationHelper.instance_method(:t).bind(self).call(key, **options)
  end
 
  delegate :back_link_to, to: :helpers
  delegate :default_form_builder, to: :controller
end
