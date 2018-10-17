namespace :globalize do
  def translatable_classes
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
    ]
  end

  def migrate_data
    @errored = false

    translatable_classes.each do |model_class|
      logger.info "Migrating #{model_class} data"

      fields = model_class.translated_attribute_names

      model_class.find_each do |record|
        fields.each do |field|
          locale = if model_class == SiteCustomization::Page && record.locale.present?
                     record.locale
                   else
                     I18n.locale
                   end

          if record.send(:"#{field}_#{locale}").blank?
            record.send(:"#{field}_#{locale}=", record.untranslated_attributes[field.to_s])
          end
        end

        begin
          record.save!
        rescue ActiveRecord::RecordInvalid
          logger.error "Failed to save #{model_class} with id #{record.id}"
          @errored = true
        end
      end
    end
  end

  def logger
    @logger ||= Logger.new(STDOUT).tap do |logger|
      logger.formatter = proc { |severity, _datetime, _progname, msg| "#{severity} #{msg}\n" }
    end
  end

  def errored?
    @errored
  end

  desc "Simulates migrating existing data to translation tables"
  task simulate_migrate_data: :environment do
    logger.info "Starting migrate data simulation"

    ActiveRecord::Base.transaction do
      migrate_data
      raise ActiveRecord::Rollback
    end

    if errored?
      logger.error "Simulation failed! Please check the errors and solve them before proceeding."
      raise "Simulation failed!"
    else
      logger.info "Migrate data simulation ended successfully"
    end
  end

  desc "Migrates existing data to translation tables"
  task migrate_data: :simulate_migrate_data do
    logger.info "Starting data migration"
    migrate_data
    logger.info "Finished data migration"
  end
end
