require "rails_helper"

describe Newsletter do
  let(:newsletter) { build(:newsletter) }

  it "is valid" do
    expect(newsletter).to be_valid
  end

  it "is not valid without a subject" do
    newsletter.subject = nil
    expect(newsletter).not_to be_valid
  end

  it "is not valid without a segment_recipient" do
    newsletter.segment_recipient = nil
    expect(newsletter).not_to be_valid
  end

  it "is not valid with an inexistent user segment for segment_recipient" do
    newsletter.segment_recipient = "invalid_user_segment_name"
    expect(newsletter).not_to be_valid
  end

  it "is not valid without a from" do
    newsletter.from = nil
    expect(newsletter).not_to be_valid
  end

  it "is not valid without a body" do
    newsletter.body = nil
    expect(newsletter).not_to be_valid
  end

  it "validates from attribute email format" do
    newsletter.from = "this_is_not_an_email"
    expect(newsletter).not_to be_valid
  end

  describe "#valid_segment_recipient?" do
    it "is false when segment_recipient value is invalid" do
      newsletter.update(segment_recipient: "invalid_segment_name")
      error = "The user recipients segment is invalid"

      expect(newsletter).not_to be_valid
      expect(newsletter.errors.messages[:segment_recipient]).to include(error)
    end
  end

  describe "#list_of_recipient_emails" do

    before do
      create(:user, newsletter: true, email: "newsletter_user@consul.dev")
      create(:user, newsletter: false, email: "no_news_user@consul.dev")
      create(:user, email: "erased_user@consul.dev").erase
      newsletter.update(segment_recipient: "all_users")
    end

    it "returns list of recipients excluding users with disabled newsletter" do
      expect(newsletter.list_of_recipient_emails.count).to eq(1)
      expect(newsletter.list_of_recipient_emails).to include("newsletter_user@consul.dev")
      expect(newsletter.list_of_recipient_emails).not_to include("no_news_user@consul.dev")
      expect(newsletter.list_of_recipient_emails).not_to include("erased_user@consul.dev")
    end
  end

  describe "#deliver" do
    let!(:proposals) { Array.new(3) { create(:proposal) } }
    let!(:debate) { create(:debate) }

    let!(:recipients) { proposals.map(&:author).map(&:email) }
    let!(:newsletter) { create(:newsletter, segment_recipient: "proposal_authors") }

    before do
      reset_mailer
      Delayed::Worker.delay_jobs = true
    end

    after do
      Delayed::Worker.delay_jobs = false
    end

    it "sends an email with the newsletter to every recipient" do
      newsletter.deliver

      recipients.each do |recipient|
        email = Mailer.newsletter(newsletter, recipient)
        expect(email).to deliver_to(recipient)
      end

      Delayed::Job.all.map(&:invoke_job)
      expect(ActionMailer::Base.deliveries.count).to eq(3)
    end

    it "sends emails in batches" do
      allow(newsletter).to receive(:batch_size).and_return(1)

      newsletter.deliver

      expect(Delayed::Job.count).to eq(3)
    end

    it "sends batches in time intervals" do
      allow(newsletter).to receive(:batch_size).and_return(1)
      allow(newsletter).to receive(:batch_interval).and_return(1.second)
      allow(newsletter).to receive(:first_batch_run_at).and_return(Time.current)

      newsletter.deliver

      now = newsletter.first_batch_run_at
      first_batch_run_at  = now.change(usec: 0)
      second_batch_run_at = (now + 1.second).change(usec: 0)
      third_batch_run_at  = (now + 2.seconds).change(usec: 0)

      expect(Delayed::Job.count).to eq(3)
      expect(Delayed::Job.first.run_at.change(usec: 0)).to eq(first_batch_run_at)
      expect(Delayed::Job.second.run_at.change(usec: 0)).to eq(second_batch_run_at)
      expect(Delayed::Job.third.run_at.change(usec: 0)).to eq(third_batch_run_at)
    end

    it "logs users that have received the newsletter" do
      newsletter.deliver

      expect(Activity.count).to eq(3)

      recipients.each do |email|
        user = User.where(email: email).first
        activity = Activity.where(user: user).first

        expect(activity.user_id).to eq(user.id)
        expect(activity.action).to eq("email")
        expect(activity.actionable).to eq(newsletter)
      end
    end

    it "skips invalid emails" do
      Proposal.destroy_all

      valid_email = "john@gmail.com"
      invalid_email = "john@gmail..com"

      valid_email_user = create(:user, email: valid_email)
      proposal = create(:proposal, author: valid_email_user)

      invalid_email_user = create(:user, email: invalid_email)
      proposal = create(:proposal, author: invalid_email_user)

      newsletter.deliver

      expect(Activity.count).to eq(1)
      expect(Activity.first.user_id).to eq(valid_email_user.id)
      expect(Activity.first.action).to eq("email")
      expect(Activity.first.actionable).to eq(newsletter)
    end

  end
end
