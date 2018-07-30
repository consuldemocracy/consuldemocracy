class Tenant < ApplicationRecord
  validates :subdomain,
    presence: true,
    uniqueness: true,
    exclusion: { in: ->(*) { excluded_subdomains }}
  validates :name, presence: true

  after_create :create_schema
  after_update :rename_schema
  after_destroy :destroy_schema

  def self.excluded_subdomains
    Apartment::Elevators::Subdomain.excluded_subdomains + %w[mail]
  end

  def self.switch(...)
    Apartment::Tenant.switch(...)
  end

  private

    def create_schema
      Apartment::Tenant.create(subdomain)
    end

    def rename_schema
      if saved_change_to_subdomain?
        ActiveRecord::Base.connection.execute(
          "ALTER SCHEMA \"#{subdomain_before_last_save}\" RENAME TO \"#{subdomain}\";"
        )
      end
    end

    def destroy_schema
      Apartment::Tenant.drop(subdomain)
    end
end
