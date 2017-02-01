module TagsHelper

  def taggables_path(taggable_type, tag_name)
    case taggable_type
    when 'debate'
      debates_path(search: tag_name)
    when 'proposal'
      proposals_path(search: tag_name)
    when 'budget/investment'
      budget_investments_path(@budget, search: tag_name)
    else
      '#'
    end
  end

  def display_tag_list(resource)
    tag_list = resource.tag_list.to_s

    if resource.tag_list.count == 1
       tag_list += ","
    end
    tag_list
  end

  def taggable_path(taggable)
    taggable_type = taggable.class.name.underscore
    case taggable_type
    when 'debate'
      debate_path(taggable)
    when 'proposal'
      proposal_path(taggable)
    when 'budget/investment'
      budget_investment_path(taggable.budget_id, taggable)
    else
      '#'
    end
  end

end
