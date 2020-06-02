class Tenant < ApplicationRecord
  validates :schema,
    presence: true,
    uniqueness: true,
    exclusion: { in: ->(*) { excluded_subdomains }}
  validates :name, presence: true, uniqueness: true

  after_create :create_schema
  after_update :rename_schema
  after_destroy :destroy_schema

  def self.excluded_subdomains
    Apartment::Elevators::Subdomain.excluded_subdomains + %w[mail shared_extensions]
  end

  def self.switch(...)
    Apartment::Tenant.switch(...)
  end

  private

    def create_schema
      Apartment::Tenant.create(schema)
    end

    def rename_schema
      if saved_change_to_schema?
        ActiveRecord::Base.connection.execute(
          "ALTER SCHEMA \"#{schema_before_last_save}\" RENAME TO \"#{schema}\";"
        )
      end
    end

    def destroy_schema
      Apartment::Tenant.drop(schema)
    end
end
