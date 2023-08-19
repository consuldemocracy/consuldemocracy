class CreateSharedExtensionsSchema < ActiveRecord::Migration[6.0]
  def up
    unless schema_exists?(extensions_schema)
      execute_or_log_create_schema_warning("CREATE SCHEMA #{extensions_schema}")
    end

    %w[unaccent pg_trgm].each do |extension|
      if extension_enabled?(extension)
        unless extension_already_in_extensions_schema?(extension)
          execute_or_log_extension_warning("ALTER EXTENSION #{extension} SET SCHEMA #{extensions_schema}")
        end
      else
        execute_or_log_extension_warning("CREATE EXTENSION #{extension} SCHEMA #{extensions_schema}")
      end
    end

    unless schema_exists?(extensions_schema) && public_has_usage_privilege_on_extensions_schema?
      execute_or_log_grant_usage_warning("GRANT usage ON SCHEMA #{extensions_schema} TO public")
    end

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

    def execute_or_log_create_schema_warning(statement)
      if create_permission?
        execute statement
      else
        log_warning(
          "GRANT CREATE ON DATABASE #{query_value("SELECT CURRENT_DATABASE()")} "\
          "TO #{query_value("SELECT CURRENT_USER")}"
        )
        log_warning(statement)
      end
    end

    def execute_or_log_extension_warning(statement)
      if superuser?
        execute statement
      else
        log_warning(statement)
      end
    end

    def execute_or_log_grant_usage_warning(statement)
      if schema_exists?(extensions_schema) && grant_usage_permission?
        execute statement
      else
        log_warning(statement)
      end
    end

    def create_permission?
      query_value("SELECT has_database_privilege(CURRENT_USER, CURRENT_DATABASE(), 'CREATE');")
    end

    def superuser?
      query_value("SELECT usesuper FROM pg_user WHERE usename = CURRENT_USER")
    end

    def grant_usage_permission?
      query_value("SELECT has_schema_privilege(CURRENT_USER, '#{extensions_schema}', 'CREATE');")
    end

    def public_has_usage_privilege_on_extensions_schema?
      query_value("SELECT has_schema_privilege('public', '#{extensions_schema}', 'USAGE');")
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
          CONSUL DEMOCRACY installation.

          NOTE: If you aren't going to use multitenancy, you can safely
          ignore this warning.

          If you'd like to enable this feature, first run:
            #{warning_messages.join(";\n    ")};
          using a user with enough database privileges.

          Check the CONSUL DEMOCRACY release notes for more information.
        ------------------------------------------------------------------
      WARNING

      puts message
      Rails.logger.warn(message)
    end
end
