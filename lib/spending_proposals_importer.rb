class SpendingProposalsImporter

  def import(sp)
    # feasibility
    # unfeasibility_explanation
    # heading_id
    # valuator_assignments_count
    # hidden_at
    # comments_count
    # group_id
    # budget_id
    # duration

    # comments

    budget = Budget.last || Budget.create!(name: Date.today.year.to_s, currency_symbol: "€")

    group = nil
    heading = nil

    if sp.geozone_id.present?
      group   = budget.groups.find_or_create_by!(name: "Barrios")
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

    Budget::Investment.create!(
      heading_id: heading.id,
      author_id: sp.author_id,
      administrator_id: sp.administrator_id,
      title: sp.title,
      description: sp.description,
      external_url: sp.external_url,
      price: sp.price,
      price_explanation: sp.price_explanation,
      internal_comments: sp.internal_comments,
      feasibility: feasibility,
      valuation_finished: sp.valuation_finished,
      price_first_year: sp.price_first_year,
      cached_votes_up: sp.cached_votes_up,
      physical_votes: sp.physical_votes,
      created_at: sp.created_at,
      updated_at: sp.updated_at,
      responsible_name: sp.responsible_name,
      terms_of_service: "1"
    )
  end

end

