module RemotelyTranslatable

  private

    def detect_remote_translations(*args)
      return [] unless Setting["feature.remote_translations"].present?

      resources_groups(*args).flatten.select { |resource| translation_empty?(resource) }.map do |resource|
        remote_translation_for(resource)
      end
    end

    def remote_translation_for(resource)
      { "remote_translatable_id" => resource.id.to_s,
        "remote_translatable_type" => resource.class.to_s,
        "locale" => I18n.locale }
    end

    def translation_empty?(resource)
      resource.translations.where(locale: I18n.locale).empty?
    end

    def resources_groups(*args)
      feeds = args.detect { |arg| arg&.first.class == Widget::Feed } || []

      args.compact - [feeds] + feeds.map(&:items)
    end

end
