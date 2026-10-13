class Layout::RemoteTranslationsButtonComponent < ApplicationComponent
  attr_reader :record_or_records
  delegate :current_order, to: :helpers

  def initialize(record_or_records)
    @record_or_records = record_or_records
  end

  def remote_translations
    @remote_translations ||= if record_or_records.respond_to?(:comments)
                               detect_remote_translations([record_or_records], comments)
                             else
                               detect_remote_translations(record_or_records)
                             end
  end

  def render?
    remote_translations.present? &&
      RemoteTranslations::Caller.available_locales.include?(I18n.locale.to_s)
  end

  def detect_remote_translations(*)
    return [] unless remote_translation_enabled?

    RemoteTranslation.for(*)
  end

  private

    def translations_in_progress?
      remote_translations.any?(&:enqueued?)
    end

    def comments
      CommentTree.new(record_or_records, params[:page], current_order).comments
    end

    def remote_translation_enabled?
      RemoteTranslations::Caller.configured?
    end
end
