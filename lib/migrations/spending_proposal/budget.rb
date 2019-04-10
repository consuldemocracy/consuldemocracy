require_dependency "spending_proposal"

class Migrations::SpendingProposal::Budget
  include Migrations::SpendingProposal::Common

  def migrate
    setup
    migrate_data
    expire_caches
  end

  def setup
    initial_rake_task
    update_heading_price
    update_heading_population
  end

  def migrate_data
    migrate_budget_investments
    migrate_votes
    migrate_ballots
  end

  def expire_caches
    update_cached_votes
    update_cached_ballots
    calculate_winners
  end

  private

    def initial_rake_task
      log("Starting to migrate spending proposals to budget investments")
      SpendingProposal.find_each { |sp| MigrateSpendingProposalsToInvestments.new.import(sp) }
      log("Finished")
    end

    def migrate_budget_investments
      update_selected_investments
      Migrations::SpendingProposal::BudgetInvestments.new.update_all
    end

    def migrate_votes
      Migrations::SpendingProposal::Vote.new.create_budget_investment_votes
    end

    def migrate_ballots
      Migrations::SpendingProposal::Ballots.new.migrate_all
    end

    def update_heading_price
      update_city_heading_price
      update_district_heading_price
    end

    def update_city_heading_price
      budget.headings.where(name: city_heading).first&.update(price: city_price)
    end

    def update_district_heading_price
      price_by_heading.each do |heading_name, price|
        budget.headings.where(name: heading_name).first&.update(price: price)
      end
    end

    def update_heading_population
      update_city_heading_population
      update_district_heading_population
    end

    def update_city_heading_population
      budget.headings.where(name: "Toda la ciudad").first&.update(population: city_population)
    end

    def update_district_heading_population
      population_by_heading.each do |heading_name, population|
        budget.headings.where(name: heading_name).first&.update(population: population)
      end
    end

    def city_population
      population_by_heading.collect {|district, population| population}.sum
    end

    def update_selected_investments
      ::SpendingProposal.feasible.valuation_finished.each do |spending_proposal|
        find_budget_investment(spending_proposal)&.update(selected: true)
      end
    end

    def update_cached_votes
      budget.investments.map(&:update_cached_votes)
    end

    def update_cached_ballots
      budget.investments.each do |investment|
        ballot_lines_count = budget.lines.where(investment: investment).count
        investment.update(ballot_lines_count: ballot_lines_count)
      end
    end

    def calculate_winners
      budget.headings.each do |heading|
        Budget::Result.new(budget, heading).calculate_winners
      end
    end

end
