module RemotelyTranslatable

  private

    def detect_remote_translations(*args)
      remote_translations = []
      if Setting["feature.remote_translations"].present?
        resources_groups = prepare_resources(*args)

        resources_groups.each do |resources_group|
          resources_group.each do |resource|
            add_resource(resource, remote_translations)
          end

        end
      end
      remote_translations
    end

    def add_resource(resource, remote_translations)
      remote_translations << remote_translation_for(resource) if translation_empty?(resource)
    end

    def remote_translation_for(resource)
      { remote_translatable_id: resource.id.to_s,
        remote_translatable_type: resource.class.to_s,
        locale: I18n.locale }
    end

    def translation_empty?(resource)
      resource.translations.where(locale: I18n.locale).empty?
    end

    def prepare_resources(*args)
      resources_groups = []
      args.compact.each do |resources_group|

        next resources_groups << resources_group unless is_widget_feeds?(resources_group)
        resources_group.each do |feed|
          resources_groups << feed.items
        end

      end
      resources_groups
    end

    def is_widget_feeds?(resources_group)
      resources_group.present? && resources_group.first.class == Widget::Feed
    end
end
