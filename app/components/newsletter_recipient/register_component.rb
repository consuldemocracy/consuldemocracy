class NewsletterRecipient::RegisterComponent < ApplicationComponent
  attr_reader :newsletter_recipient

  def initialize
    @newsletter_recipient = NewsletterRecipient.new
  end
end
