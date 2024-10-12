class Shared::DateOfBirthFieldComponent < ApplicationComponent
  attr_reader :form, :options

  def initialize(form, **options)
    @form = form
    @options = options
  end

  private

    def default_options
      {
        min: "1900-01-01",
        max: minimum_required_age.years.ago
      }
    end

    def field_options
      default_options.merge(options)
    end

    def minimum_required_age
      User.minimum_required_age
    end
end
