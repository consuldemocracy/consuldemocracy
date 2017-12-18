class MigrateSpendingProposalsToInvestments

  def import(sp)
    budget = Budget.find_or_create_by(name: '2016', phase: 'finished', currency_symbol: "€")

    group = nil
    heading = nil
    community = Community.create

    if sp.geozone_id.present?
      group   = budget.groups.find_or_create_by!(name: "Distritos")
      heading = group.headings.find_or_create_by!(name: sp.geozone.name, price: 10000000)
    else
      group   = budget.groups.find_or_create_by!(name: "Toda la ciudad")
      heading = group.headings.find_or_create_by!(name: "Toda la ciudad", price: 10000000)
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
      author_id: sp.author_id,
      administrator_id: sp.administrator_id,
      title: sp.title,
      description: sp.description,
      external_url: sp.external_url,
      price: sp.price,
      feasibility: feasibility,
      price_explanation: sp.price_explanation,
      unfeasibility_explanation: sp.id, # MIGRATE THIS correctly
      internal_comments: sp.internal_comments,
      valuation_finished: sp.valuation_finished,
      valuator_assignments_count: sp.valuation_assignments_count,
      price_first_year: sp.price_first_year,
      duration: sp.time_scope,
      hidden_at: sp.hidden_at,
      cached_votes_up: sp.cached_votes_up,
      comments_count: sp.comments_count,
      confidence_score: sp.confidence_score,
      physical_votes: sp.physical_votes,
      tsv: sp.tsv,
      created_at: sp.created_at,
      updated_at: sp.updated_at,
      heading_id: heading.id,
      responsible_name: sp.responsible_name,
      budget_id: budget.id,
      group_id: group.id,
      selected: false, # FIND VALUE FOR THIS ONE
      location: nil, # FIND VALUE FOR THIS ONE
      organization_name: sp.association_name,
      unfeasible_email_sent_at: sp.unfeasible_email_sent_at,
      label: nil,
      previous_heading_id: nil, # FIND VALUE FOR THIS ONE
      visible_to_valuators: false, # FIND VALUE FOR THIS ONE
      ballot_lines_count: sp.ballot_lines_count,
      winner: false, # FIND VALUE FOR THIS ONE
      incompatible: !sp.compatible, # Is it really the opposite?
      community_id: community.id,
      terms_of_service: "1"
    )

    investment.valuators = sp.valuation_assignments.map(&:valuator)

    # For now we avoind replicating votes
    # votes = ActsAsVotable::Vote.where(votable_type: 'SpendingProposal', votable_id: sp.id)
    # votes.each {|v| investment.vote_by(voter: v.voter, vote: 'yes') }

    # Spending proposals are not commentable in Consul so we can not test this
    Comment.where(commentable_type: 'SpendingProposal', commentable_id: sp.id).update_all(
      commentable_type: 'Budget::Investment', commentable_id: investment.id
    )
    Budget::Investment.reset_counters(investment.id, :comments)

    # Spending proposals have ballot_lines in Madrid, but not in consul, so we
    # can not test this either

    sp.update_column(:explanations_log, investment.id) # Backwards reference to unfeasibility_explanation

    investment
  end

end

