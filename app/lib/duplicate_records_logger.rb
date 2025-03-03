class DuplicateRecordsLogger
  def info(message)
    logger.info(message)
  end

  def logger
    @logger ||= ActiveSupport::Logger.new(log_file).tap do |logger|
      logger.formatter = Rails.application.config.log_formatter
    end
  end

  private

    def log_file
      File.join(File.dirname(Rails.application.config.default_log_file), log_filename)
    end

    def log_filename
      "duplicate_records.log"
    end
end
