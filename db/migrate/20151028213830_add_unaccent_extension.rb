class AddUnaccentExtension < ActiveRecord::Migration
  def change
    return if extension_enabled?('unaccent')

    begin
      enable_extension 'unaccent'
    rescue StandardError => e
      raise "Could not create extension unaccent. Please contact with your system administrator: #{e}"
    end
  end
end
