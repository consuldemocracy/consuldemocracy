class Budget
  class Result

    attr_accessor :budget, :heading, :money_spent, :current_investment

    def initialize(budget, heading)
      @budget = budget
      @heading = heading
    end

    def calculate_winners
      reset_winners
      investments.compatible.each do |investment|
        @current_investment = investment
        set_winner if inside_budget?
      end
    end

    def investments
      heading.investments.selected.sort_by_ballots
    end

    def inside_budget?
      available_budget >= @current_investment.price
    end

    def available_budget
      total_budget - money_spent
    end

    def total_budget
      heading.price
    end

    def money_spent
      @money_spent ||= 0
    end

    def reset_winners
      investments.update_all(winner: false)
    end

    def set_winner
      @money_spent += @current_investment.price
      @current_investment.update(winner: true)
    end

    def winners
      investments.where(winner: true)
    end

  end
end
