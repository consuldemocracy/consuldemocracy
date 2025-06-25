require "rails_helper"

describe Polls::FormComponent do
  let(:user) { create(:user, :level_two) }
  let(:poll) { create(:poll) }
  let(:web_vote) { Poll::WebVote.new(poll, user) }
  before { create(:poll_question, :yes_no, poll: poll) }

  it "renders disabled fields when the user has already voted in a booth" do
    create(:poll_voter, :from_booth, poll: poll, user: user)
    sign_in(user)

    render_inline Polls::FormComponent.new(web_vote)

    page.find("fieldset[disabled]") do |fieldset|
      expect(fieldset).to have_field "Yes"
      expect(fieldset).to have_field "No"
    end

    expect(page).to have_button "Vote", disabled: true
  end

  it "renders disabled answers to unverified users" do
    sign_in(create(:user, :incomplete_verification))

    render_inline Polls::FormComponent.new(web_vote)

    page.find("fieldset[disabled]") do |fieldset|
      expect(fieldset).to have_field "Yes"
      expect(fieldset).to have_field "No"
    end

    expect(page).to have_button "Vote", disabled: true
  end

  context "expired poll" do
    let(:poll) { create(:poll, :expired) }

    it "renders disabled fields when the poll has expired" do
      sign_in(user)

      render_inline Polls::FormComponent.new(web_vote)

      page.find("fieldset[disabled]") do |fieldset|
        expect(fieldset).to have_field "Yes"
        expect(fieldset).to have_field "No"
      end

      expect(page).to have_button "Vote", disabled: true
    end
  end

  context "geozone restricted poll" do
    let(:poll) { create(:poll, geozone_restricted: true) }
    let(:geozone) { create(:geozone) }
    before { poll.geozones << geozone }

    context "user from another geozone" do
      let(:user) { create(:user, :level_two) }
      before { sign_in(user) }

      it "renders disabled fields" do
        render_inline Polls::FormComponent.new(web_vote)

        page.find("fieldset[disabled]") do |fieldset|
          expect(fieldset).to have_field "Yes"
          expect(fieldset).to have_field "No"
        end

        expect(page).to have_button "Vote", disabled: true
      end
    end

    context "user from the same geozone" do
      let(:user) { create(:user, :level_two, geozone: geozone) }
      before { sign_in(user) }

      it "renders enabled answers" do
        render_inline Polls::FormComponent.new(web_vote)

        expect(page).not_to have_css "fieldset[disabled]"
        expect(page).to have_field "Yes"
        expect(page).to have_field "No"
        expect(page).to have_button "Vote"
      end
    end
  end
end
