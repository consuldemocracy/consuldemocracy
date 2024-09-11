require "rails_helper"

describe Comments::FormComponent do
  context "Legislation annotation" do
    it "disables comments when the allegations phase is closed" do
      process = create(:legislation_process,
                       allegations_start_date: 1.month.ago,
                       allegations_end_date: Date.yesterday)

      version = create(:legislation_draft_version, process: process)
      annotation = create(:legislation_annotation, draft_version: version, text: "One annotation")

      render_inline Comments::FormComponent.new(annotation)

      expect(page).to have_content "Comments are closed"
      expect(page).not_to have_content "Leave your comment"
      expect(page).not_to have_button "Publish comment"
    end
  end

  context "Legislation question" do
    let(:process) { create(:legislation_process, :in_debate_phase) }
    let(:question) { create(:legislation_question, process: process) }

    it "prevents unverified users from creating comments" do
      unverified_user = create(:user)
      sign_in unverified_user

      render_inline Comments::FormComponent.new(question)

      expect(page).to have_content "To participate verify your account"
    end

    it "blocks comment creation when the debate phase is not open" do
      user = create(:user, :level_two)
      process.update!(debate_start_date: Date.current - 2.days, debate_end_date: Date.current - 1.day)
      sign_in(user)

      render_inline Comments::FormComponent.new(question)

      expect(page).to have_content "Closed phase"
    end
  end
end
