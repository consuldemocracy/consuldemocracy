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
      { 'remote_translatable_id' => resource.id.to_s,
        'remote_translatable_type' => resource.class.to_s,
        'locale' => I18n.locale }
    end

    def translation_empty?(resource)
      resource.translations.where(locale: I18n.locale).empty?
    end

    def prepare_resources(*args)
      widgets_group = get_widget_group(*args)
      resources_groups = get_resources_groups(*args)
      add_widgets_to_resources_groups(resources_groups, widgets_group)
    end

    def get_widget_group(*args)
      widget_feeds = args.compact.select { |arg| is_widget_feeds?(arg) }
    end

    def get_resources_groups(*args)
      args.compact.select { |arg| is_resources_group?(arg) }
    end

    def add_widgets_to_resources_groups(resources_groups, widgets_group)
      return resources_groups unless widgets_group.present?

      widgets_group.first.each do |feed|
        resources_groups << feed.items
      end

      resources_groups
    end

    def is_widget_feeds?(resources_group)
      resources_group.present? && resources_group.first.class == Widget::Feed
    end

    def is_resources_group?(resources_group)
      !is_widget_feeds?(resources_group)
    end
end
