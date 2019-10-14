module CustomHelper

  NESTED_POLYMORPHIC_URLS_MODELS = [Budget::Investment]

  def format_price(number)
    number_to_currency(number, precision: 0, locale: I18n.default_locale)
  end

  def commissions_as_options(current=nil)

    # TODO - Improve this implementation (did it as workaround because time restricitions)
    options_from_collection_for_select(Commission.order('name'), 'id', 'name', current)
  end

  def link_to_commentable_safe(comment)

    # GET-62 moderate comments in Budgets::Investments

    if comment.commentable.is_a?(Budget::Investment)
      link_to comment.commentable.title, budget_investment_url(comment.commentable.budget, comment.commentable)
    else
      link_to comment.commentable.title, comment.commentable
    end
  end

  def assembly_types_for_menu
    ConsulAssemblies::AssemblyType.order(:name)
  end

  def build_newsletter_options
    [["Acepta notificaciones", true], ["No acepta notificaciones", false]]
  end

end
