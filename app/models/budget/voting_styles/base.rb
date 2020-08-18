class Budget::VotingStyles::Base
  attr_reader :ballot

  def initialize(ballot)
    @ballot = ballot
  end

  def name
    self.class.name.split("::").last.underscore
  end

  def change_vote_info(link:)
    I18n.t("budgets.investments.index.sidebar.change_vote_info.#{name}", link: link)
  end

  def voted_info(heading)
    I18n.t("budgets.investments.index.sidebar.voted_info.#{name}",
      count: investments(heading).count,
      amount_spent: ballot.budget.formatted_amount(investments_price(heading)))
  end

  def amount_available_info(heading)
    I18n.t("budgets.ballots.show.amount_available.#{name}",
           count: formatted_amount_available(heading))
  end

  def amount_spent_info(heading)
    I18n.t("budgets.ballots.show.amount_spent.#{name}",
           count: formatted_amount_spent(heading))
  end

  def amount_limit_info(heading)
    I18n.t("budgets.ballots.show.amount_limit.#{name}",
           count: formatted_amount_limit(heading))
  end

  def amount_available(heading)
    amount_limit(heading) - amount_spent(heading)
  end

  def percentage_spent(heading)
    100.0 * amount_spent(heading) / amount_limit(heading)
  end

  def formatted_amount_available(heading)
    format(amount_available(heading))
  end

  def formatted_amount_spent(heading)
    format(amount_spent(heading))
  end

  def formatted_amount_limit(heading)
    format(amount_limit(heading))
  end

  private

    def investments(heading)
      ballot.investments.by_heading(heading.id)
    end

    def investments_price(heading)
      investments(heading).sum(:price).to_i
    end
end
