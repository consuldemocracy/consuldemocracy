
require_dependency Rails.root.join('app', 'models', 'budget').to_s

class Budget < ApplicationRecord

  def self.current_budget
    current.last
  end

  def self.last_budget
    finished.last
  end

  def total_amount
    headings.map(&:price).sum

  end

  def can_create_investment_by_user(user)
    if user.organization? && !user.organization.verified?
      return :association_not_verified
    else
      return :already_created
    end
  end

end
