class Budget::Phase::Translation < Globalize::ActiveRecord::Translation
  before_validation :sanitize_description

  private

    def sanitize_description
      self.description = WYSIWYGSanitizer.new.sanitize(description)
    end
end
