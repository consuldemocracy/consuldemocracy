require "rails_helper"

describe Dashboard::Mailer do

  describe "#new_actions_notification_on_create" do

    before do
      ActionMailer::Base.deliveries.clear
    end

    let!(:proposal) { build(:proposal, :draft) }
    let!(:action)   { create(:dashboard_action, :proposed_action, :active,
                              day_offset: 0,
                              published_proposal: true) }
    let!(:resource) { create(:dashboard_action, :resource, :active,
                              day_offset: 0,
                              published_proposal: true) }

    it "sends emails when detect new actions when create a proposal" do
      action.update(published_proposal: false)
      resource.update(published_proposal: false)
      proposal.save

      email = open_last_email

      expect(email).to deliver_from("CONSUL <noreply@consul.dev>")
      expect(email).to deliver_to(proposal.author)
      expect(email).to have_subject("Your draft citizen proposal in Decide Madrid is created")
      expect(email).to have_body_text("Hi #{proposal.author.name}!")
      expect(email).to have_body_text("Your #{proposal.title} proposal has been successfully created.")
      expect(email).to have_body_text("Take advantage that your proposal is not public yet and get ready to contact a lot of people.")
      expect(email).to have_body_text(I18n.t("mailers.new_actions_notification_on_create.text_2", link: proposal_dashboard_url(proposal)).html_safe)
      expect(email).to have_body_text("We know that creating a proposal with a hook and getting the necessary support can seem complicated. But dont worry because we are going to help you!")
      expect(email).to have_body_text("You have a tool that will be your new best ally: The Citizen Proposals panel.")
      expect(email).to have_body_text("Enter every day in the panel of your proposal to use the tips and resources that we will share with you.")
      expect(email).to have_body_text("These tips, actions and resources will give you ideas and also practical solutions to get more support and a wider community. Dont forget them!")
      expect(email).to have_body_text("As you gain more support, you will unlock new and better resources. At the moment, you have an e-mail template to send massively to all your contacts, a poster to print, among other features and rewards that you will discover. Dont stop adding support and we will not stop rewarding and helping you!")
      expect(email).to have_body_text("You have #{Setting['months_to_archive_proposals']} months since you publish the proposal to get #{Setting['votes_for_proposal_success']} support and your proposal can become a reality. But the first days are the most important. It is a challenge. Get ready!")
      expect(email).to have_body_text("And for you to start with all the motivation,")
      expect(email).to have_body_text("here you have several resources and a whole list of tips that will come to you every day to prepare the broadcast!")
      expect(email).to have_body_text("Go ahead, discover them!")
    end
  end
end
