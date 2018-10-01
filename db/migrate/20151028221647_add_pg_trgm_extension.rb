class AddPgTrgmExtension < ActiveRecord::Migration
  def change
    return if extension_enabled?('pg_trgm')

    begin
      enable_extension 'pg_trgm'
    rescue StandardError => e
      raise "Could not create extension pg_trgm. Please contact with your system administrator: #{e}"
    end
  end
end
