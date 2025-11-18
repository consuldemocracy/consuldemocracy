class Layout::RemoteTranslationsButtonComponent < ApplicationComponent
  attr_reader :remote_translations

  def initialize(remote_translations)
    @remote_translations = remote_translations
  end

  def render?
    remote_translations.present? &&
      RemoteTranslations::Caller.available_locales.include?(I18n.locale.to_s)
  end

  private

    def translations_in_progress?
      remote_translations.any?(&:enqueued?)
    end
end
