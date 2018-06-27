class String

  def self.valid_email?(string)
    !string.nil? && string&.match(/\A([^@\s?]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i).present?
  end

end