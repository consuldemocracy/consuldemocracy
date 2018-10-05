namespace :globalize do
  desc "Migrates existing data to translation tables"
  task migrate_data: :environment do
    [
      AdminNotification,
      Banner,
      Budget::Investment::Milestone,
      I18nContent,
      Legislation::DraftVersion,
      Legislation::Process,
      Legislation::Question,
      Legislation::QuestionOption,
      Poll,
      Poll::Question,
      Poll::Question::Answer,
      SiteCustomization::Page,
      Widget::Card
    ].each do |model_class|
      Logger.new(STDOUT).info "Migrating #{model_class} data"

      fields = model_class.translated_attribute_names

      model_class.find_each do |record|
        fields.each do |field|
          if record.send(:"#{field}_#{I18n.locale}").blank?
            record.send(:"#{field}_#{I18n.locale}=", record.untranslated_attributes[field.to_s])
          end
        end

        record.save!
      end
    end
  end
end
