require "rails_helper"

describe Dashboard::Mailer do
  let!(:action) do
    create(:dashboard_action, :proposed_action, :active, day_offset: 0, published_proposal: true)
  end

  let!(:resource) do
    create(:dashboard_action, :resource, :active, day_offset: 0, published_proposal: true)
  end

  before do
    Setting["feature.dashboard.notification_emails"] = true
    Setting["mailer_from_name"] = "CONSUL"
    Setting["mailer_from_address"] = "noreply@consul.dev"
  end

  describe "#forward" do
    let!(:proposal) { create(:proposal) }

    before do
      ActionMailer::Base.deliveries.clear
    end

    it "Disables notification emails delivery using setting, does not affect the forward email" do
      Setting["feature.dashboard.notification_emails"] = nil

      Dashboard::Mailer.forward(proposal).deliver_now

      expect(ActionMailer::Base.deliveries.count).to eq(1)
    end

    it "sends forward email" do
      Dashboard::Mailer.forward(proposal).deliver_now

      email = open_last_email

      expect(email).to deliver_from("CONSUL <noreply@consul.dev>")
      expect(email).to deliver_to(proposal.author)
      expect(email).to have_subject(proposal.title)
      expect(email).to have_body_text("Support this proposal")
      expect(email).to have_body_text("Share in")
      expect(email).to have_body_text(proposal_path(proposal))
    end
  end

  describe "#new_actions_notification_on_create" do
    before do
      ActionMailer::Base.deliveries.clear
    end

    let!(:proposal) { build(:proposal, :draft) }

    it "Disables notification email delivery using setting" do
      Setting["feature.dashboard.notification_emails"] = nil

      action.update!(published_proposal: false)
      resource.update!(published_proposal: false)
      proposal.save!

      expect(ActionMailer::Base.deliveries.count).to eq(0)
    end

    it "sends emails if new actions detected when creating a proposal" do
      Setting["org_name"] = "CONSUL"
      action.update!(published_proposal: false)
      resource.update!(published_proposal: false)
      proposal.save!

      email = open_last_email

      expect(email).to deliver_from("CONSUL <noreply@consul.dev>")
      expect(email).to deliver_to(proposal.author)
      expect(email).to have_subject("Your draft citizen proposal is created")
      expect(email).to have_body_text("Hi #{proposal.author.name}!")
      expect(email).to have_body_text("Your #{proposal.title} proposal has been "\
                                      "successfully created.")
      expect(email).to have_body_text("Take advantage that your proposal is not public yet and "\
                                      "get ready to contact a lot of people.")
      expect(email).to have_body_text("When you are ready publish your citizen proposal from this")
      expect(email).to have_link "link", href: proposal_dashboard_url(proposal)
      expect(email).to have_body_text("We know that creating a proposal with a hook and getting "\
                                      "the necessary support can seem complicated. But don't "\
                                      "worry because we are going to help you!")
      expect(email).to have_body_text("You have a tool that will be your new best ally: "\
                                      "The Citizen Proposals panel.")
      expect(email).to have_body_text("Enter every day in the panel of your proposal to use the "\
                                      "tips and resources that we will share with you.")
      expect(email).to have_body_text("These tips, actions and resources will give you ideas and "\
                                      "also practical solutions to get more support and a wider "\
                                      "community. Dont forget them!")
      expect(email).to have_body_text("As you gain more support, you will unlock new and better "\
                                      "resources. At the moment, you have an e-mail template to "\
                                      "send massively to all your contacts, a poster to print, "\
                                      "among other features and rewards that you will discover. "\
                                      "Dont stop adding support and we will not stop rewarding "\
                                      "and helping you!")
      expect(email).to have_body_text("You have #{Setting["months_to_archive_proposals"]} months "\
                                      "since you publish the proposal to get "\
                                      "#{Setting["votes_for_proposal_success"]} support and your "\
                                      "proposal can become a reality. But the first days are the "\
                                      "most important. It is a challenge. Get ready!")
      expect(email).to have_body_text("And for you to start with all the motivation,")
      expect(email).to have_body_text("here you have several resources and a whole list of "\
                                      "tips that will come to you every day to prepare the "\
                                      "broadcast!")
      expect(email).to have_body_text("Go ahead, discover them!")
    end
  end

  describe "#new_actions_notification_on_published" do
    before do
      ActionMailer::Base.deliveries.clear

      create(:dashboard_action, :resource, :active, day_offset: 0, published_proposal: true)
      create(:dashboard_action, :proposed_action, :active, day_offset: 0, published_proposal: true)
    end

    let!(:proposal) { build(:proposal, :draft) }

    it "Disables notification email delivery using setting" do
      Setting["feature.dashboard.notification_emails"] = nil

      proposal.save!
      proposal.publish

      expect(ActionMailer::Base.deliveries.count).to eq(0)
    end

    it "sends emails when detect new actions when publish a proposal" do
      proposal.save!
      proposal.publish

      email = open_last_email

      expect(email).to deliver_from("CONSUL <noreply@consul.dev>")
      expect(email).to deliver_to(proposal.author)
      expect(email).to have_subject("Your citizen proposal is already "\
                                    "published. Don't stop spreading!")
      expect(email).to have_body_text("Congratulations #{proposal.author.name}! Your proposal "\
                                      "#{proposal.title} has been created successfully.")
      expect(email).to have_body_text("And now, go for your first 100 supports!")
      expect(email).to have_body_text("Why 100?")
      expect(email).to have_body_text("Our experience tells us that the first day is fundamental. "\
                                      "Because in addition to having the energy to launch "\
                                      "something new, being a newly published proposal, you will "\
                                      "have the important visibility of being among the new "\
                                      "proposals highlighted.")
      expect(email).to have_body_text("Get 100 supports on the first day, and you will have "\
                                      "a first community to back you up.")
      expect(email).to have_body_text("That is why we challenge you to get it, but not without "\
                                      "a lot of help!")
      expect(email).to have_body_text("Remember that in your Proposal Panel you have new "\
                                      "resources available and recommendations for "\
                                      "dissemination actions.")
      expect(email).to have_body_text("Come in every day to see your progress and use the tips "\
                                      "and resources we will share with you. They are ideas and "\
                                      "also practical solutions to get the support you need.")
      expect(email).to have_body_text("As you get more support, you will unlock new and better "\
                                      "resources. Do not stop adding support and we will not stop "\
                                      "rewarding and helping you!")
      expect(email).to have_body_text("And for you to start at full speed...")
      expect(email).to have_body_text("Here is a great resource at your disposal!")
      expect(email).to have_body_text("You will also find this new recommended dissemination "\
                                      "action...")
      expect(email).to have_body_text("You sure have more resources to use!")
      expect(email).to have_body_text("Go ahead, discover them!")
    end
  end
end
