require "rails_helper"

describe Mailer do
  describe "#comment" do
    before do
      allow_any_instance_of(ActionMailer::MessageDelivery).to receive(:deliver_later), &:deliver_now
    end

    it "sends emails in the user's locale" do
      user = create(:user, locale: "es")
      proposal = create(:proposal, author: user)
      comment = create(:comment, commentable: proposal)

      email = I18n.with_locale :en do
        Mailer.comment(comment)
      end

      expect(email.subject).to include("comentado")
    end

    it "reads the from address at runtime" do
      Setting["mailer_from_name"] = "New organization"
      Setting["mailer_from_address"] = "new@consul.dev"

      email = Mailer.comment(create(:comment))

      expect(email).to deliver_from "New organization <new@consul.dev>"
    end

    it "sends emails for comments on legislation proposals" do
      email = Mailer.comment(create(:legislation_proposal_comment))

      expect(email.subject).to include("commented on your proposal")
    end

    context "Proposal comments" do
      let(:user)     { create(:user, email_on_comment: true) }
      let(:proposal) { create(:proposal, author: user) }

      it "Send email on proposal comment" do
        comment_on(proposal)

        email = open_last_email
        expect(email).to have_subject "Someone has commented on your citizen proposal"
        expect(email).to deliver_to(proposal.author)
        expect(email).to have_body_text proposal_path(proposal)
        expect(email).to have_body_text "To unsubscribe from these emails, visit"
        expect(email).to have_body_text edit_subscriptions_path(token: proposal.author.subscriptions_token)
        expect(email).to have_body_text 'and uncheck "Notify me by email when someone ' \
                                        'comments on my contents"'
      end

      it "Do not send email about own proposal comments" do
        comment_on(proposal, user)
        expect { open_last_email }.to raise_error "No email has been sent!"
      end

      it "Do not send email about proposal comment unless set in preferences" do
        user.update!(email_on_comment: false)
        comment_on(proposal)
        expect { open_last_email }.to raise_error "No email has been sent!"
      end
    end

    context "Debate comments" do
      let(:user)   { create(:user, email_on_comment: true) }
      let(:debate) { create(:debate, author: user) }

      scenario "Send email on debate comment" do
        comment_on(debate)

        email = open_last_email
        expect(email).to have_subject "Someone has commented on your debate"
        expect(email).to deliver_to(debate.author)
        expect(email).to have_body_text debate_path(debate)
        expect(email).to have_body_text "To unsubscribe from these emails, visit"
        expect(email).to have_body_text edit_subscriptions_path(token: debate.author.subscriptions_token)
        expect(email).to have_body_text 'and uncheck "Notify me by email when someone ' \
                                        'comments on my contents"'
      end

      scenario "Do not send email about own debate comments" do
        comment_on(debate, user)
        expect { open_last_email }.to raise_error "No email has been sent!"
      end

      scenario "Do not send email about debate comment unless set in preferences" do
        user.update!(email_on_comment: false)
        comment_on(debate)
        expect { open_last_email }.to raise_error "No email has been sent!"
      end
    end

    context "Budget investments comments" do
      let(:user)       { create(:user, email_on_comment: true) }
      let(:investment) { create(:budget_investment, author: user, budget: create(:budget)) }

      scenario "Send email on budget investment comment" do
        comment_on(investment)

        email = open_last_email
        expect(email).to have_subject "Someone has commented on your investment"
        expect(email).to deliver_to(investment.author)
        expect(email).to have_body_text budget_investment_path(investment, budget_id: investment.budget_id)
        expect(email).to have_body_text "To unsubscribe from these emails, visit"
        expect(email).to have_body_text edit_subscriptions_path(token: investment.author.subscriptions_token)
        expect(email).to have_body_text 'and uncheck "Notify me by email when someone ' \
                                        'comments on my contents"'
      end

      scenario "Do not send email about own budget investments comments" do
        comment_on(investment, user)
        expect { open_last_email }.to raise_error "No email has been sent!"
      end

      scenario "Do not send email about budget investment comment unless set in preferences" do
        user.update!(email_on_comment: false)
        comment_on(investment)
        expect { open_last_email }.to raise_error "No email has been sent!"
      end
    end

    context "Topic comments" do
      let(:user)     { create(:user, email_on_comment: true) }
      let(:proposal) { create(:proposal) }
      let(:topic)    { create(:topic, author: user, community: proposal.community) }

      scenario "Send email on topic comment" do
        comment_on(topic)

        email = open_last_email
        expect(email).to have_subject "Someone has commented on your topic"
        expect(email).to deliver_to(topic.author)
        expect(email).to have_body_text community_topic_path(topic, community_id: topic.community_id)
        expect(email).to have_body_text "To unsubscribe from these emails, visit"
        expect(email).to have_body_text edit_subscriptions_path(token: topic.author.subscriptions_token)
        expect(email).to have_body_text 'and uncheck "Notify me by email when someone ' \
                                        'comments on my contents"'
      end

      scenario "Do not send email about own topic comments" do
        comment_on(topic, user)
        expect { open_last_email }.to raise_error "No email has been sent!"
      end

      scenario "Do not send email about topic comment unless set in preferences" do
        user.update!(email_on_comment: false)
        comment_on(topic)
        expect { open_last_email }.to raise_error "No email has been sent!"
      end
    end

    context "Poll comments" do
      let(:user) { create(:user, email_on_comment: true) }
      let(:poll) { create(:poll, author: user) }

      scenario "Send email on poll comment" do
        comment_on(poll)

        email = open_last_email
        expect(email).to have_subject "Someone has commented on your poll"
        expect(email).to deliver_to(poll.author)
        expect(email).to have_body_text poll_path(poll)
        expect(email).to have_body_text "To unsubscribe from these emails, visit"
        expect(email).to have_body_text edit_subscriptions_path(token: poll.author.subscriptions_token)
        expect(email).to have_body_text 'and uncheck "Notify me by email when someone ' \
                                        'comments on my contents"'
      end

      scenario "Do not send email about own poll comments" do
        comment_on(poll, user)
        expect { open_last_email }.to raise_error "No email has been sent!"
      end

      scenario "Do not send email about poll question comment unless set in preferences" do
        user.update!(email_on_comment: false)
        comment_on(poll)
        expect { open_last_email }.to raise_error "No email has been sent!"
      end
    end

    def comment_on(commentable, user = nil)
      user ||= create(:user)

      comment = create(:comment, commentable: commentable, user: user)
      CommentNotifier.new(comment: comment).process
    end
  end

  describe "#user_invite" do
    it "uses the default locale setting" do
      Setting["locales.default"] = "es"

      Mailer.user_invite("invited@consul.dev").deliver_now

      expect(ActionMailer::Base.deliveries.last.body.to_s).to match "<html lang=\"es\""
    end
  end

  describe "#manage_subscriptions_token" do
    let(:user) { create(:user) }
    let(:proposal) { create(:proposal, author: user) }
    let(:comment) { create(:comment, commentable: proposal) }

    it "generates a subscriptions token when the receiver doesn't have one" do
      user.update!(subscriptions_token: nil)

      Mailer.comment(comment).deliver_now

      expect(user.reload.subscriptions_token).to be_present
    end

    it "uses the existing subscriptions token when the receivesr already has one" do
      user.update!(subscriptions_token: "subscriptions_token_value")

      Mailer.comment(comment).deliver_now

      expect(user.subscriptions_token).to eq "subscriptions_token_value"
    end
  end

  describe "multitenancy" do
    it "uses the current tenant when using delayed jobs", :delay_jobs do
      allow(ActionMailer::Base).to receive(:default_url_options).and_return({ host: "consul.dev" })
      create(:tenant, schema: "delay")

      Tenant.switch("delay") do
        Setting["org_name"] = "Delayed tenant"

        Mailer.delay.user_invite("test@consul.dev")
      end

      Delayed::Worker.new.work_off
      body = ActionMailer::Base.deliveries.last.body.to_s
      expect(body).to match "Delayed tenant"
      expect(body).to match "href=\"http://delay.consul.dev/"
      expect(body).to match "src=\"http://delay.consul.dev/"
    end

    describe "SMTP settings" do
      let(:default_settings) { { address: "mail.consul.dev", username: "main" } }
      let(:super_settings) { { address: "super.consul.dev", username: "super" } }

      before do
        stub_secrets(
          smtp_settings: default_settings,
          tenants: {
            supermailer: { smtp_settings: super_settings }
          }
        )
      end

      it "does not overwrite the settings for the default tenant" do
        Mailer.user_invite("test@consul.dev").deliver_now

        expect(ActionMailer::Base.deliveries.last.delivery_method.settings).to eq({})
      end

      it "uses specific secret settings for tenants overwriting them" do
        allow(Tenant).to receive(:current_schema).and_return("supermailer")

        Mailer.user_invite("test@consul.dev").deliver_now

        expect(ActionMailer::Base.deliveries.last.delivery_method.settings).to eq super_settings
      end

      it "uses the default secret settings for other tenants" do
        allow(Tenant).to receive(:current_schema).and_return("ultramailer")

        Mailer.user_invite("test@consul.dev").deliver_now

        expect(ActionMailer::Base.deliveries.last.delivery_method.settings).to eq default_settings
      end
    end
  end

  describe "#machine_learning_success" do
    let(:admin) { create(:administrator) }

    it "is delivered to the user who executes the script" do
      Mailer.machine_learning_success(admin.user).deliver

      email = open_last_email
      expect(email).to have_subject "Machine Learning - Content has been generated successfully"
      expect(email).to have_content "Machine Learning script"
      expect(email).to have_content "Content has been generated successfully."
      expect(email).to have_link "Visit Machine Learning panel"
      expect(email).to deliver_to(admin.user.email)
    end
  end

  describe "#machine_learning_error" do
    let(:admin) { create(:administrator) }

    it "is delivered to the user who executes the script" do
      Mailer.machine_learning_error(admin.user).deliver

      email = open_last_email
      expect(email).to have_subject "Machine Learning - An error has occurred running the script"
      expect(email).to have_content "Machine Learning script"
      expect(email).to have_content "An error has occurred running the Machine Learning script."
      expect(email).to have_link "Visit Machine Learning panel"
      expect(email).to deliver_to(admin.user.email)
    end
  end
end
