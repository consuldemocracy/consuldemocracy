class Tenant < ApplicationRecord
  validates :subdomain,
    presence: true,
    uniqueness: true,
    exclusion: { in: ->(*) { excluded_subdomains }},
    format: { with: URI::DEFAULT_PARSER.regexp[:HOST] }
  validates :subdomain, format: { without: /\./ }
  validates :name, presence: true

  after_create :create_schema
  after_update :rename_schema
  after_destroy :destroy_schema

  def self.resolve_host(host)
    return nil unless Rails.application.config.multitenancy.present?
    return nil if host.blank? || host.match?(Resolv::AddressRegex)

    dev_domains = %w[localhost lvh.me example.com]
    allowed_domains = dev_domains + [default_host]
    host_domain = allowed_domains.find { |domain| host == domain || host.ends_with?(".#{domain}") }

    host.delete_prefix("www.").sub(/\.?#{host_domain}\Z/, "").presence
  end

  def self.excluded_subdomains
    %w[mail public shared_extensions www]
  end

  def self.default_host
    ActionMailer::Base.default_url_options[:host]
  end

  def self.current_schema
    Apartment::Tenant.current
  end

  def self.default?
    current_schema == "public"
  end

  def self.switch(...)
    Apartment::Tenant.switch(...)
  end

  def self.run_on_each(&block)
    ["public"].union(Apartment.tenant_names).each do |subdomain|
      switch(subdomain, &block)
    end
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
