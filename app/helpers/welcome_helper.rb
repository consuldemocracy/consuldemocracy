module WelcomeHelper

  def active_class(index)
    "is-active is-in" if index == 0
  end

  def slide_display(index)
    "display: none;" if index > 0
  end

  def recommended_path(recommended)
    case recommended.class.name
    when "Debate"
      debate_path(recommended)
    when "Proposal"
      proposal_path(recommended)
    when "Budget::Investment"
      budget_investment_path(budget_id: recommended.budget.id, id: recommended.id)
    else
      '#'
    end
  end

  def render_image(recommended, image_field, image_version, image_default)
    image_path =  if image_field.present? && image_version.present?
                    recommended.send("#{image_field}", image_version)
                  elsif image_default.present?
                    image_default
                  end
    image_tag(image_path) if image_path.present?
  end

  def calculate_size(debates, proposals, budget_investments)
    size =  debates.any? && proposals.any? && budget_investments.any? ? 4 : 6
    "medium-#{size} large-#{size}"
  end

  def calculate_centered(debates, proposals, budget_investments)
    if debates.blank? && proposals.blank? && budget_investments.any?   ||
       debates.blank? && proposals.any?   && budget_investments.blank? ||
       debates.any?   && proposals.blank? && budget_investments.blank?
        centered = "medium-centered large-centered"
    end
  end

  def calculate_carousel_size(debates, proposals, budget_investments)
    size = calculate_size(debates, proposals, budget_investments)
    centered = calculate_centered(debates, proposals, budget_investments)
    "#{size} #{centered if centered}"
  end

  def display_recommendeds(debates, proposals, budget_investments)
    debates.any? || proposals.any? || budget_investments.any?
  end

end
