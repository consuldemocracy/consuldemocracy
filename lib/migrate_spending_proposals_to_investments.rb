class MigrateSpendingProposalsToInvestments

  def import(sp)
    budget = Budget.last || Budget.create!(name: Date.current.year.to_s, currency_symbol: "€")

    group = nil
    heading = nil

    if sp.geozone_id.present?
      group   = budget.groups.find_or_create_by!(name: "Barrios")
      heading = group.headings.find_or_create_by!(name: sp.geozone.name, price: 10000000, latitude: '40.416775', longitude: '-3.703790')
    else
      group   = budget.groups.find_or_create_by!(name: "Toda la ciudad")
      heading = group.headings.find_or_create_by!(name: "Toda la ciudad", price: 10000000, latitude: '40.416775', longitude: '-3.703790')
    end

    feasibility = case sp.feasible
                  when FalseClass
                    'unfeasible'
                  when TrueClass
                    'feasible'
                  else
                    'undecided'
                  end

    investment = Budget::Investment.create!(
      heading_id: heading.id,
      author_id: sp.author_id,
      administrator_id: sp.administrator_id,
      title: sp.title,
      description: sp.description,
      external_url: sp.external_url,
      price: sp.price,
      price_explanation: sp.price_explanation,
      duration: sp.time_scope,
      feasibility: feasibility,
      unfeasibility_explanation: sp.feasible_explanation,
      valuation_finished: sp.valuation_finished,
      price_first_year: sp.price_first_year,
      cached_votes_up: sp.cached_votes_up,
      physical_votes: sp.physical_votes,
      created_at: sp.created_at,
      updated_at: sp.updated_at,
      responsible_name: sp.responsible_name,
      terms_of_service: "1"
    )

    investment.valuators = sp.valuation_assignments.map(&:valuator)

    votes = ActsAsVotable::Vote.where(votable_type: 'SpendingProposal', votable_id: sp.id)

    votes.each {|v| investment.vote_by(voter: v.voter, vote: 'yes') }

    # Spending proposals are not commentable in Consul so we can not test this
    #
    # Comment.where(commentable_type: 'SpendingProposal', commentable_id: sp.id).update_all(
    #   commentable_type: 'Budget::Investment', commentable_id: investment.id
    # )
    # Budget::Investment.reset_counters(investment.id, :comments)

    # Spending proposals have ballot_lines in Madrid, but not in consul, so we
    # can not test this either

    investment
  end

end

