class CreateSharedExtensionsSchema < ActiveRecord::Migration[6.0]
  def up
    create_schema(extensions_schema) unless schema_exists?(extensions_schema)

    %w[unaccent pg_trgm].each do |extension|
      if extension_enabled?(extension)
        unless extension_already_in_extensions_schema?(extension)
          execute_or_log_warning("ALTER EXTENSION #{extension} SET SCHEMA #{extensions_schema}")
        end
      else
        execute_or_log_warning("CREATE EXTENSION #{extension} SCHEMA #{extensions_schema}")
      end
    end

    execute "GRANT usage ON SCHEMA #{extensions_schema} TO public"

    show_full_warning_message if warning_messages.any?
  end

  def down
    %w[unaccent pg_trgm].each do |extension|
      unless extension_already_in_public_schema?(extension)
        execute "ALTER EXTENSION #{extension} SET SCHEMA public;"
      end
    end

    execute "DROP SCHEMA #{extensions_schema};" if schema_exists?(extensions_schema)
  end

  private

    def extensions_schema
      "shared_extensions"
    end

    def extension_already_in_extensions_schema?(extension)
      associated_schema_id_for(extension) == extensions_schema_id
    end

    def extension_already_in_public_schema?(extension)
      associated_schema_id_for(extension) == public_schema_id
    end

    def associated_schema_id_for(extension)
      query_value("SELECT extnamespace FROM pg_extension WHERE extname=#{quote(extension)}")
    end

    def extensions_schema_id
      schema_id_for(extensions_schema)
    end

    def public_schema_id
      schema_id_for("public")
    end

    def schema_id_for(schema)
      query_value("SELECT oid FROM pg_namespace WHERE nspname=#{quote(schema)}")
    end

    def execute_or_log_warning(statement)
      if superuser?
        execute statement
      else
        log_warning(statement)
      end
    end

    def superuser?
      query_value("SELECT usesuper FROM pg_user where usename = CURRENT_USER")
    end

    def log_warning(statement)
      warning_messages.push(statement)
    end

    def warning_messages
      @warning_messages ||= []
    end

    def show_full_warning_message
      message = <<~WARNING
        ---------------------- Multitenancy Warning ----------------------
          Multitenancy is a feature that allows managing multiple
          institutions in a completely independent way using just one
          CONSUL installation.

          NOTE: If you aren't going to use multitenancy, you can safely
          ignore this warning.

          If you'd like to enable this feature, first run:
            #{@warning_messages.join(";\n    ")};
          using a user with enough database privileges.

          Check the CONSUL release notes for more information.
        ------------------------------------------------------------------
      WARNING

      puts message
      Rails.logger.warn(message)
    end
end
