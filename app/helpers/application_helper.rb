module ApplicationHelper
  def percentage(vote, debate)
    return "0%" if debate.total_votes == 0
    debate.send(vote).percent_of(debate.total_votes).to_s + "%"
  end

  def home_page?
    # Using path because fullpath yields false negatives since it contains
    # parameters too
    request.path == '/'
  end

  def header_css
    home_page? ? '' : 'results'
  end

  def available_locale_options_for_select
    options_for_select(available_locales_array, I18n.locale)
  end

  private
    def available_locales_array
      I18n.available_locales.map { |loc| [I18n.t('locale', locale: loc), loc] }
    end

end
