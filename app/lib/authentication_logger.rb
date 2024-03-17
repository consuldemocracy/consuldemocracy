class AuthenticationLogger
  @loggers = {}

  class << self
    def log(message)
      logger.tagged(Time.current) do
        logger.info(message)
      end
    end

    def path
      Rails.root.join("log", Tenant.subfolder_path, "authentication.log")
    end

    private

      def logger
        @loggers[Apartment::Tenant.current] ||= build_logger
      end

      def build_logger
        FileUtils.mkdir_p(File.dirname(path))
        ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new(path, level: :info))
      end
  end
end
