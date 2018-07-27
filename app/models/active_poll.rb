class ActivePoll < ActiveRecord::Base
  include Measurable

  def self.description
    return nil unless self.any?
    self.first.description
  end
end
