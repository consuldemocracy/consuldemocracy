namespace :migrations do
  desc "Add name to existing budget phases"
  task add_name_to_existing_budget_phases: :environment do
    Budget::Phase.find_each do |phase|
      unless phase.name.present?
        if phase.translations.present?
          phase.translations.each do |translation|
            unless translation.name.present?
              if I18n.available_locales.include? translation.locale
                locale = translation.locale
              else
                locale = I18n.default_locale
              end
              i18n_name = I18n.t("budgets.phase.#{translation.globalized_model.kind}", locale: locale)
              translation.update!(name: i18n_name)
            end
          end
        else
          phase.translations.create!(name: I18n.t("budgets.phase.#{phase.kind}"), locale: I18n.default_locale)
        end
      end
    end
  end

  desc "Copies the Budget::Phase summary into description"
  task budget_phases_summary_to_description: :environment do
    Budget::Phase::Translation.find_each do |phase|
      if phase.summary.present?
        phase.description << "<br>"
        phase.description << phase.summary
        phase.update!(summary: nil) if phase.save
      end
    end
  end

  desc "Migrates map location settings"
  task migrate_map_location_settings: :environment do
    latitude  = Setting["map.latitude"]
    longitude = Setting["map.longitude"]
    zoom      = Setting["map.zoom"]

    if latitude.present? || longitude.present? || zoom.present?
      map_location = Map.default.map_location

      if latitude.present?
        map_location.latitude = latitude.to_f
        map_location.save!
        Setting.remove("map.latitude")
      end

      if longitude.present?
        map_location.longitude = longitude.to_f
        map_location.save!
        Setting.remove("map.longitude")
      end

      if zoom.present?
        map_location.zoom = zoom
        map_location.save!
        Setting.remove("map.zoom")
      end
    end
  end
end
