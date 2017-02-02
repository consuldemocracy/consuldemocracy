
require_dependency Rails.root.join('app', 'models', 'budget').to_s


class Budget < ActiveRecord::Base

  def self.current_budget
    current.last
  end

end
