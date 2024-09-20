class UserSegments
  def self.segments
    static_segments + budget_segments
  end

  def self.segment_name(segment)
    if budget_segment?(segment)
      budget_segment_name(segment)
    else
      geozones[segment.to_s]&.name || I18n.t("admin.segment_recipient.#{segment}") if valid_segment?(segment)
    end
  end

  def self.all_users
    User.active.where.not(confirmed_at: nil)
  end

  def self.administrators
    all_users.administrators
  end

  def self.all_proposal_authors
    author_ids(Proposal.pluck(:author_id))
  end

  def self.proposal_authors
    author_ids(Proposal.not_archived.not_retired.pluck(:author_id))
  end

  def self.investment_authors
    author_ids(current_budget_investments.pluck(:author_id))
  end

  def self.feasible_and_undecided_investment_authors
    unfeasible_and_finished_condition = "feasibility = 'unfeasible' and valuation_finished = true"
    investments = current_budget_investments.where.not(unfeasible_and_finished_condition)
    author_ids(investments.pluck(:author_id))
  end

  def self.selected_investment_authors
    author_ids(current_budget_investments.selected.pluck(:author_id))
  end

  def self.winner_investment_authors
    author_ids(current_budget_investments.winners.pluck(:author_id))
  end

  def self.not_supported_on_current_budget
    author_ids(
      User.where.not(
        id: Vote.select(:voter_id).where(votable: current_budget_investments).distinct
      )
    )
  end

  def self.valid_segment?(segment)
    segments.include?(segment.to_s)
  end

  def self.recipients(segment)
    if geozones[segment.to_s]
      all_users.where(geozone: geozones[segment.to_s])
    else
      send(segment)
    end
  end

  def self.user_segment_emails(segment)
    recipients(segment).newsletter.order(:created_at).pluck(:email).compact
  end

  private

  def self.static_segments
    %w[all_users
       administrators
       all_proposal_authors
       proposal_authors
       investment_authors
       feasible_and_undecided_investment_authors
       selected_investment_authors
       winner_investment_authors
       not_supported_on_current_budget] + geozones.keys
  end

  def self.budget_segments
    open_budgets.map do |budget|
      %W[
        #{budget.name}_all_proposal_authors
        #{budget.name}_proposal_authors
        #{budget.name}_investment_authors
        #{budget.name}_feasible_and_undecided_investment_authors
        #{budget.name}_selected_investment_authors
        #{budget.name}_winner_investment_authors
      ]
    end.flatten
  end

  def self.open_budgets
    Budget.where.not(phase: "finished").order(created_at: :desc).limit(2)
  end

  def self.budget_segment?(segment)
    open_budgets.any? { |budget| segment.start_with?(budget.name) }
  end

  def self.budget_segment_name(segment)
    budget_name = segment.split('_').first
    segment_type = segment.sub("#{budget_name}_", '')

    budget = open_budgets.find { |b| b.name == budget_name }
    I18n.t("admin.segment_recipient.#{segment_type}", budget_name: budget.name)
  end

  def self.current_budget_investments
    Budget.current.investments
  end

  def self.author_ids(author_ids)
    all_users.where(id: author_ids)
  end

  def self.geozones
    Geozone.order(:name).to_h do |geozone|
      [geozone.name.gsub(/./) { |char| character_approximation(char) }.underscore.tr(" ", "_"), geozone]
    end
  end

  def self.character_approximation(char)
    I18n::Backend::Transliterator::HashTransliterator::DEFAULT_APPROXIMATIONS[char] || char
  end
end
