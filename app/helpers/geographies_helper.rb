module GeographiesHelper

  def related_heading_name(heading_id)
      related_heading = Budget::Heading.find(heading_id)
      link_to related_heading.name, budget_investments_path(budget_id: related_heading.budget_id , heading_id: related_heading.id)
  end

  def link_to_document(document)
      link_to document.title, document.attachment.url
  end

end
