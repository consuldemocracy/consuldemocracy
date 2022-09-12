require_dependency Rails.root.join("app", "models", "budget").to_s

class Budget < ApplicationRecord
  def investments_orders
    case phase
    when "accepting", "reviewing"
      %w[random]
    when "publishing_prices", "balloting", "reviewing_ballots"
      %w[random price]
    else
      %w[random confidence_score]
    end
  end
end
