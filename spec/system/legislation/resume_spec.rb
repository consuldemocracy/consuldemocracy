require "rails_helper"

describe "Legislation" do
  context "process resume page" do

    scenario "resume tab not show" do
      process = create(:legislation_process, :open)
      visit legislation_process_path(process)
      expect(page).not_to have_content("Resume")
    end

    scenario "resume tab show" do
      process = create(:legislation_process, :past)
      visit legislation_process_path(process)
      expect(page).to have_content("Resume")
    end
  end

  context "process empty" do
    before do
      @process = create(:legislation_process, :empty, end_date: Date.current - 1.days)
    end

    scenario "warning empty" do
      visit resume_legislation_process_path(@process)
      expect(page).to have_content("The process have no phases.")
    end
  end

  context "phases empty" do
    before do
      @process = create(:legislation_process, end_date: Date.current - 1.days)
    end

    scenario "debates empty" do
      visit resume_legislation_process_path(@process)
      expect(page).to have_content("Debates phase")
      expect(page).to have_content("No debates")
      expect(page).to have_content("There aren't any questions")
    end

    scenario "proposals empty" do
      visit resume_legislation_process_path(@process)
      expect(page).to have_content("Proposal phase")
      expect(page).to have_content("No proposals")
      expect(page).to have_content("There are no proposals")
    end

    scenario "text comments empty" do
      visit resume_legislation_process_path(@process)
      expect(page).to have_content("Text comment phase")
      expect(page).to have_content("No comments")
      expect(page).to have_content("There are no text comments")
    end
  end

  context "process empty" do
    before do
      @process = create(:legislation_process, :empty, end_date: Date.current - 1.days)
    end

    scenario "warning empty" do
      visit resume_legislation_process_path(@process)
      expect(page).to have_content("The process have no phases.")
    end
  end

  context "only debates exist" do
    before do
      user = create(:user, :level_two)
      @process = create(:legislation_process, end_date: Date.current - 1.days)
      @debate = create(:legislation_question, process: @process, title: "Question 1")
      create(:debate_comment, user: user, commentable_id: @debate.id, body: "Answer 1")
      create(:debate_comment, user: user, commentable_id: @debate.id, body: "Answer 2")
      @debate = create(:legislation_question, process: @process, title: "Question 2")
      create(:debate_comment, user: user, commentable_id: @debate.id, body: "Answer 3")
      create(:debate_comment, user: user, commentable_id: @debate.id, body: "Answer 4")


    end

    scenario "show debates list" do
      visit resume_legislation_process_path(@process)
      expect(page).to have_content("Debates phase")
      expect(page).to have_content("2 debates")

      expect(page).to have_content("Question 1")
      expect(page).to have_content("Answer 1")
      expect(page).to have_content("Answer 2")
      expect(page).to have_content("Question 2")
      expect(page).to have_content("Answer 3")
      expect(page).to have_content("Answer 4")

      click_link "Question 1"
      expect(page).to have_content("Question 1")
      expect(page).to have_content("Answer 1")
      expect(page).to have_content("Answer 2")
      expect(page).not_to have_content("Answer 3")
      expect(page).not_to have_content("Answer 4")

      visit resume_legislation_process_path(@process)
      click_link "Question 2"
      expect(page).to have_content("Question 2")
      expect(page).not_to have_content("Answer 1")
      expect(page).not_to have_content("Answer 2")
      expect(page).to have_content("Answer 3")
      expect(page).to have_content("Answer 4")

    end

    scenario "proposals empty" do
      visit resume_legislation_process_path(@process)
      expect(page).to have_content("Proposal phase")
      expect(page).to have_content("No proposals")
      expect(page).to have_content("There are no proposals")
    end

    scenario "text comments empty" do
      visit resume_legislation_process_path(@process)
      expect(page).to have_content("Text comment phase")
      expect(page).to have_content("No comments")
      expect(page).to have_content("There are no text comments")
    end
  end

  context "only proposals exist" do
    before do
      @process = create(:legislation_process, end_date: Date.current - 1.days)
      create(:legislation_proposal, legislation_process_id: @process.id,
             title: "Legislation proposal 1", selected: true)
      create(:legislation_proposal, legislation_process_id: @process.id,
             title: "Legislation proposal 2", selected: false)
      create(:legislation_proposal, legislation_process_id: @process.id,
             title: "Legislation proposal 3", selected: true)
      create(:legislation_proposal, legislation_process_id: @process.id,
             title: "Legislation proposal 4", selected: false)
    end

    scenario "debates empty" do
      visit resume_legislation_process_path(@process)
      expect(page).to have_content("Debates phase")
      expect(page).to have_content("No debates")
      expect(page).to have_content("There aren't any questions")
    end

    scenario "proposals empty" do
      visit resume_legislation_process_path(@process)
      expect(page).to have_content("Proposal phase")
      expect(page).to have_content("2 proposals")

      expect(page).to have_content("Legislation proposal 1")
      expect(page).not_to have_content("Legislation proposal 2")
      expect(page).to have_content("Legislation proposal 3")
      expect(page).not_to have_content("Legislation proposal 4")

      click_link "Legislation proposal 1"
      expect(page).to have_content("Legislation proposal 1")

      visit resume_legislation_process_path(@process)
      click_link "Legislation proposal 3"
      expect(page).to have_content("Legislation proposal 3")

    end

    scenario "text comments empty" do
      visit resume_legislation_process_path(@process)
      expect(page).to have_content("Text comment phase")
      expect(page).to have_content("No comments")
      expect(page).to have_content("There are no text comments")
    end
  end

  context "only text comments exist" do
    before do
      user = create(:user, :level_two)
      @process = create(:legislation_process, end_date: Date.current - 1.days)
      draft_version_1 = create(:legislation_draft_version, process: @process,
                               title: "Version 1", body: "Body of the first version",
                               status: "published")
      draft_version_2 = create(:legislation_draft_version, process: @process,
                               title: "Version 2", body: "Body of the second version and that's it all of it",
                               status: "published")
      annotation0 = create(:legislation_annotation,
                           draft_version: draft_version_1, text: "my annotation123",
                           ranges: [{"start" => "/p[1]", "startOffset" => 5, "end" => "/p[1]", "endOffset" => 10}])
      annotation1 = create(:legislation_annotation,
                           draft_version: draft_version_2, text: "hola",
                           ranges: [{"start" => "/p[1]", "startOffset" => 5, "end" => "/p[1]", "endOffset" => 10}])
      annotation2 = create(:legislation_annotation,
                           draft_version: draft_version_2,
                           ranges: [{"start" => "/p[1]", "startOffset" => 12, "end" => "/p[1]", "endOffset" => 19}])
      create(:text_comment, user: user, commentable_id: annotation0.id, body: "Comment 0")
      create(:text_comment, user: user, commentable_id: annotation1.id, body: "Comment 1")
      create(:text_comment, user: user, commentable_id: annotation2.id, body: "Comment 2")
      create(:text_comment, user: user, commentable_id: annotation2.id, body: "Comment 3")
    end

    scenario "debates empty" do
      visit resume_legislation_process_path(@process)
      expect(page).to have_content("Debates phase")
      expect(page).to have_content("No debates")
      expect(page).to have_content("There aren't any questions")
    end

    scenario "proposals empty" do
      visit resume_legislation_process_path(@process)
      expect(page).to have_content("Proposal phase")
      expect(page).to have_content("No proposals")
      expect(page).to have_content("There are no proposals")
    end

    scenario "text comments empty" do
      visit resume_legislation_process_path(@process)
      expect(page).to have_content("Text comment phase (version Version 2")
      expect(page).to have_content("5 comments")
      expect(page).not_to have_content("Comment 0")
      expect(page).to have_content("Comment 1")
      expect(page).to have_content("Comment 2")
      expect(page).to have_content("Comment 3")

      click_link "Comment 2"
      expect(page).to have_content("Comment 2")
    end

    # scenario "excel download" do
    #   visit resume_legislation_process_path(@process)
    #   click_link "Download"
    #   page.response_headers['Content-Type'].should eq "application/xlsx"
    # end

  end

  describe Legislation::ProcessesController, type: :controller do
    before do
      user = create(:user, :level_two)
      @process = create(:legislation_process, end_date: Date.current - 1.days)
      @debate = create(:legislation_question, process: @process, title: "Question 1")
      create(:debate_comment, user: user, commentable_id: @debate.id, body: "Answer 1")
      create(:debate_comment, user: user, commentable_id: @debate.id, body: "Answer 2")
    end

    it "download execl file test" do
      get :resume, params: {id: @process, format: :xlsx}
      expect(response).to be_success
    end
  end

end
