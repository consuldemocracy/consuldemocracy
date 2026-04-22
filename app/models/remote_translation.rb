class RemoteTranslation < ApplicationRecord
  belongs_to :remote_translatable, polymorphic: true

  validates :remote_translatable_id, presence: true
  validates :remote_translatable_type, presence: true
  validates :locale, presence: true
  validates :locale, inclusion: { in: ->(_) { available_locales }}
  validate :already_translated_resource
  after_commit :enqueue_remote_translation, on: :create

  def self.available_locales
    I18n.available_locales.map(&:to_s)
  end

  def self.configured?
    [Setting["llm.provider"], Setting["llm.model"],
     Setting["llm.use_llm_for_translations"]].all?(&:present?)
  end

  def enqueue_remote_translation
    delay.translate_remotely!
  end

  def translate_remotely!
    update_resource
    destroy_remote_translation
  end

  def self.for(*)
    resources_groups(*).flatten.select { |resource| translation_empty?(resource) }.map do |resource|
      new(remote_translatable: resource, locale: I18n.locale)
    end
  end

  def self.resources_groups(*args)
    feeds = args.find { |arg| arg&.first.class == Widget::Feed } || []

    args.compact - [feeds] + feeds.map(&:items)
  end

  def self.translation_empty?(resource)
    resource.class.translates? && resource.translations.where(locale: I18n.locale).empty?
  end

  def self.create_all(remote_translations_params)
    remote_translations_params.map do |remote_translation_params|
      new(remote_translation_params)
    end.reject(&:already_translated?).reject(&:enqueued?).each(&:save!)
  end

  def already_translated_resource
    if already_translated?
      errors.add(:locale, :already_translated)
    end
  end

  def enqueued?
    self.class.where(remote_translatable: remote_translatable,
                     locale: locale,
                     error_message: nil).any?
  end

  def already_translated?
    remote_translatable&.translations&.where(locale: locale).present?
  end

  private

    def update_resource
      Globalize.with_locale(locale) do
        remote_translatable.translated_attribute_names.each_with_index do |field, index|
          remote_translatable.send(:"#{field}=", translations[index])
        end
      end
      remote_translatable.save
    end

    def destroy_remote_translation
      if remote_translatable.valid?
        destroy
        remote_translatable.save!
      else
        update(error_message: remote_translatable.errors.messages)
      end
    end

    def translations
      @translations ||= RemoteTranslations::Client.new.call(fields_values, locale)
    end

    def fields_values
      remote_translatable.translated_attribute_names.map do |field|
        WYSIWYGSanitizer.new.sanitize(remote_translatable.send(field))
      end
    end
end
