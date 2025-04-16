# frozen_string_literal: true

# Vendored from https://github.com/sgruhier/foundation_rails_helper/blob/master/lib/foundation_rails_helper/configuration.rb

module FoundationRailsHelper
  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.reset
    @configuration = Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  class Configuration
    attr_accessor :button_class
    attr_accessor :ignored_flash_keys
    attr_accessor :auto_labels

    def initialize
      @button_class = 'success button'
      @ignored_flash_keys = []
      @auto_labels = true
    end
  end
end
