class MigrateSpendingProposalsToInvestments
  include Migrations::SpendingProposal::Common

  def import(sp)
    budget = Budget.find_or_create_by(name: budget_name, slug: budget_name, phase: "finished", currency_symbol: "€")

    group = nil
    heading = nil
    community = Community.create

    if sp.geozone_id.present?
      group   = budget.groups.find_or_create_by!(name: districts_heading)
      heading = group.headings.find_or_create_by!(name: sp.geozone.name, price: 10000000)
    else
      group   = budget.groups.find_or_create_by!(name: city_heading)
      heading = group.headings.find_or_create_by!(name: city_heading, price: 10000000)
    end

    feasibility = case sp.feasible
                  when FalseClass
                    "unfeasible"
                  when TrueClass
                    "feasible"
                  else
                    "undecided"
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
      unfeasibility_explanation: "-",
      valuation_finished: sp.valuation_finished,
      valuator_assignments_count: sp.valuation_assignments_count,
      price_first_year: sp.price_first_year,
      duration: sp.time_scope,
      hidden_at: sp.hidden_at,
      cached_votes_up: sp.cached_votes_up,
      comments_count: sp.comments_count,
      physical_votes: sp.physical_votes,
      tsv: sp.tsv,
      created_at: sp.created_at,
      updated_at: sp.updated_at,
      heading_id: heading.id,
      responsible_name: sp.responsible_name,
      budget_id: budget.id,
      group_id: group.id,
      selected: false,
      location: nil,
      organization_name: sp.association_name,
      unfeasible_email_sent_at: sp.unfeasible_email_sent_at,
      previous_heading_id: nil,
      visible_to_valuators: false,
      winner: false,
      community_id: community.id,
      terms_of_service: "1",
      original_spending_proposal_id: sp.id,
      skip_map: "1"
    )

    investment.valuators = sp.valuation_assignments.map(&:valuator)

    Comment.where(commentable_type: "SpendingProposal", commentable_id: sp.id).update_all(
      commentable_type: "Budget::Investment", commentable_id: investment.id
    )
    Budget::Investment.reset_counters(investment.id, :comments)

    sp.update_column(:explanations_log, investment.id)

    investment
  end

end
