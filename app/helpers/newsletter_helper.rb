module NewsletterHelper
  def available_actions(newsletter)
    if newsletter.draft? 
      { actions: [:edit, :destroy] }
    else
      { actions: [:destroy] }
    end
  end
end
