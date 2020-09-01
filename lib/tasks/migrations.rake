namespace :migrations do
  desc "Migrates context of valuation taggings"
  task valuation_taggings: :environment do
    ApplicationLogger.new.info "Updating valuation taggings context"
    Tagging.where(context: "valuation").update_all(context: "valuation_tags")
  end

  desc "Migrates budget staff"
  task budget_admins_and_valuators: :environment do
    ApplicationLogger.new.info "Updating budget administrators and valuators"
    Budget.find_each do |budget|
      investments = budget.investments.with_hidden

      budget.update!(
        administrator_ids: investments.where.not(administrator: nil).distinct.pluck(:administrator_id),
        valuator_ids: Budget::ValuatorAssignment.where(investment: investments).distinct.pluck(:valuator_id)
      )
    end
  end

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
end
