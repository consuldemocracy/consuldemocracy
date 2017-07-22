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

end
