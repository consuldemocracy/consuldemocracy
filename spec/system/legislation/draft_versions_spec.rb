require "rails_helper"

describe "Legislation Draft Versions" do
  let(:user) { create(:user) }
  let(:administrator) do
    create(:administrator, user: user)
    user
  end

  context "See draft text page" do
    let(:process) { create(:legislation_process) }

    let!(:original) do
      create(:legislation_draft_version, process: process, title: "Original",
                                         body: "Original version", status: "published")
    end

    let!(:draft) do
      create(:legislation_draft_version, process: process, title: "Draft",
                                         body: "Draft version", status: "draft")
    end

    before do
      create(:legislation_draft_version, process: process, title: "Current",
                                         body: "Current version", status: "published")
    end

    it "shows the text body for this version" do
      visit legislation_process_draft_version_path(process, original)

      expect(page).to have_content("Original version")

      within("select#draft_version_id") do
        expect(page).to have_content("Original")
        expect(page).to have_content("Current")
        expect(page).not_to have_content("Draft")
      end
    end

    it "shows an unpublished version to admins" do
      login_as(administrator)

      visit legislation_process_draft_version_path(process, draft)

      expect(page).to have_content("Draft version")

      within("select#draft_version_id") do
        expect(page).to have_content("Original")
        expect(page).to have_content("Current")
        expect(page).to have_content("Draft *")
      end
    end

    it "switches to another version without js", :no_js do
      visit legislation_process_draft_version_path(process, original)
      expect(page).to have_content("Original version")

      select("Current")
      click_button "see"

      expect(page).not_to have_content("Original version")
      expect(page).to have_content("Current version")
    end

    it "switches to another version with js" do
      visit legislation_process_draft_version_path(process, original)
      expect(page).to have_content("Original version")

      select("Current")

      expect(page).not_to have_content("Original version")
      expect(page).to have_content("Current version")
    end

    scenario "show more info button" do
      process.update!(additional_info: "Text for additional info of the process")
      visit legislation_process_draft_version_path(process, original)

      expect(page).not_to have_content "Text for additional info of the process"

      click_button "More information and context"

      expect(page).to have_content "Text for additional info of the process"
    end

    scenario "show help gif" do
      visit legislation_process_draft_version_path(process, original)

      click_button text: "How can I comment this document?"

      expect(page).to have_content "select the text you want to comment and press the button with the pencil"
    end

    context "for final versions" do
      it "does not show the comments panel" do
        final_version = create(:legislation_draft_version,
                               process: process,
                               title: "Final version",
                               body: "Final body",
                               status: "published",
                               final_version: true)

        visit legislation_process_draft_version_path(process, final_version)

        expect(page).to have_content("Final body")
        expect(page).not_to have_content("See all comments")
        within(".draft-panels") do
          expect(page).not_to have_content("Comments")
        end
      end
    end
  end

  context "See changes page" do
    let(:process) { create(:legislation_process) }

    let!(:original) do
      create(:legislation_draft_version, process: process, title: "Original", body: "Original version",
                                         changelog: "Changes for first version", status: "published")
    end

    let!(:draft) do
      create(:legislation_draft_version, process: process, title: "Draft", body: "Draft version",
                                         changelog: "Changes for third version", status: "draft")
    end

    before do
      create(:legislation_draft_version, process: process, title: "Current", body: "Current version",
                                         changelog: "Changes for second version", status: "published")
    end

    it "shows the changes for this version" do
      visit legislation_process_draft_version_changes_path(process, original)

      expect(page).to have_content("Changes for first version")

      within("select#draft_version_id") do
        expect(page).to have_content("Original")
        expect(page).to have_content("Current")
        expect(page).not_to have_content("Draft")
      end
    end

    it "shows an unpublished version to admins" do
      login_as(administrator)

      visit legislation_process_draft_version_changes_path(process, draft)

      expect(page).to have_content("Changes for third version")

      within("select#draft_version_id") do
        expect(page).to have_content("Original")
        expect(page).to have_content("Current")
        expect(page).to have_content("Draft *")
      end
    end

    it "switches to another version without js", :no_js do
      visit legislation_process_draft_version_changes_path(process, original)
      expect(page).to have_content("Changes for first version")

      select("Current")
      click_button "see"

      expect(page).not_to have_content("Changes for first version")
      expect(page).to have_content("Changes for second version")
    end

    it "switches to another version with js" do
      visit legislation_process_draft_version_changes_path(process, original)
      expect(page).to have_content("Changes for first version")

      select("Current")

      expect(page).not_to have_content("Changes for first version")
      expect(page).to have_content("Changes for second version")
    end
  end

  context "Annotations" do
    let(:user) { create(:user) }
    let(:draft_version) { create(:legislation_draft_version, :published) }

    before { login_as user }

    scenario "Visit as anonymous" do
      logout

      visit legislation_process_draft_version_path(draft_version.process, draft_version)

      page.find(:css, ".legislation-annotatable").double_click
      page.find(:css, ".annotator-adder button").click
      expect(page).not_to have_css("#legislation_annotation_text")
      expect(page).to have_content "You must sign in or sign up to leave a comment."
    end

    scenario "Create" do
      visit legislation_process_draft_version_path(draft_version.process, draft_version)

      page.find(:css, ".legislation-annotatable").double_click
      page.find(:css, ".annotator-adder button").click
      page.click_button "Publish Comment"
      expect(page).to have_content "Comment can't be blank"

      fill_in "legislation_annotation_text", with: "this is my annotation"
      page.click_button "Publish Comment"

      expect(page).to have_css ".annotator-hl"
      first(:css, ".annotator-hl").click
      expect(page).to have_content "this is my annotation"

      visit legislation_process_draft_version_path(draft_version.process, draft_version)

      expect(page).to have_css ".annotator-hl"
      first(:css, ".annotator-hl").click
      expect(page).to have_content "this is my annotation"
    end

    scenario "View annotations and comments" do
      annotation1 = create(:legislation_annotation,
                           draft_version: draft_version,
                           text: "my annotation",
                           ranges: [{ "start" => "/p[1]",
                                      "startOffset" => 5,
                                      "end" => "/p[1]",
                                      "endOffset" => 10 }])
      create(:legislation_annotation,
             draft_version: draft_version,
             text: "my other annotation",
             ranges: [{ "start" => "/p[1]", "startOffset" => 12, "end" => "/p[1]", "endOffset" => 19 }])
      comment = create(:comment, commentable: annotation1)

      visit legislation_process_draft_version_path(draft_version.process, draft_version)

      expect(page).to have_css ".annotator-hl"
      first(:css, ".annotator-hl").click
      expect(page).to have_content "my annotation"
      expect(page).to have_content comment.body

      all(".annotator-hl")[1].click
      expect(page).to have_content "my other annotation"
    end

    scenario "Publish new comment for an annotation from comments box" do
      create(:legislation_annotation,
             draft_version: draft_version,
             text: "my annotation",
             ranges: [{ "start" => "/p[1]", "startOffset" => 6, "end" => "/p[1]", "endOffset" => 11 }])

      visit legislation_process_draft_version_path(draft_version.process, draft_version)

      expect(page).to have_css ".annotator-hl"
      first(:css, ".annotator-hl").click
      expect(page).to have_content "my annotation"

      click_link "Publish Comment"
      fill_in "comment[body]", with: "My interesting comment"
      click_button "Publish comment"
      expect(page).to have_content "My interesting comment"
    end

    scenario "Publish new comment with errors for an existing annotation" do
      create(:legislation_annotation, draft_version: draft_version)

      visit legislation_process_draft_version_path(draft_version.process, draft_version)
      find(:css, ".annotator-hl").double_click
      find(:css, ".annotator-adder button").click
      click_button "Publish Comment"

      expect(page).to have_content "Comment can't be blank"
    end
  end

  context "Merged annotations" do
    let(:user) { create(:user) }
    let(:draft_version) { create(:legislation_draft_version, :published) }

    before { login_as user }

    scenario "View annotations and comments in an included range" do
      create(:legislation_annotation,
             draft_version: draft_version,
             text: "my annotation",
             ranges: [{ "start" => "/p[1]", "startOffset" => 1, "end" => "/p[1]", "endOffset" => 5 }])
      create(:legislation_annotation,
             draft_version: draft_version,
             text: "my other annotation",
             ranges: [{ "start" => "/p[1]", "startOffset" => 1, "end" => "/p[1]", "endOffset" => 10 }])

      visit legislation_process_draft_version_path(draft_version.process, draft_version)

      expect(page).to have_css ".annotator-hl"
      first(:css, ".annotator-hl").click

      within(".comment-box") do
        expect(page).to have_content "2 comment"
        expect(page).to have_content "my annotation"
        expect(page).to have_content "my other annotation"
      end
    end
  end

  context "Annotations page" do
    let(:draft_version) { create(:legislation_draft_version, :published) }

    before do
      create(:legislation_annotation,
             draft_version: draft_version,
             text: "my annotation",
             quote: "ipsum",
             ranges: [{ "start" => "/p[1]", "startOffset" => 6, "end" => "/p[1]", "endOffset" => 11 }])
      create(:legislation_annotation,
             draft_version: draft_version,
             text: "my other annotation",
             quote: "audiam",
             ranges: [{ "start" => "/p[3]", "startOffset" => 6, "end" => "/p[3]", "endOffset" => 11 }])
    end

    scenario "See all annotations for a draft version" do
      visit legislation_process_draft_version_annotations_path(draft_version.process, draft_version)

      expect(page).to have_content "ipsum"
      expect(page).to have_content "audiam"
    end

    context "switching versions" do
      let(:process)  { create(:legislation_process) }
      let(:original) { create(:legislation_draft_version, :published, process: process, title: "Original") }
      let(:current)  { create(:legislation_draft_version, :published, process: process, title: "Current") }

      before do
        create(:legislation_annotation,
               draft_version: original,
               quote: "quote for version 1",
               ranges: [{ "start" => "/p[1]", "startOffset" => 11, "end" => "/p[1]", "endOffset" => 30 }])
        create(:legislation_annotation,
               draft_version: current,
               quote: "quote for version 2",
               ranges: [{ "start" => "/p[1]", "startOffset" => 11, "end" => "/p[1]", "endOffset" => 30 }])
      end

      scenario "without js", :no_js do
        visit legislation_process_draft_version_annotations_path(process, original)
        expect(page).to have_content("quote for version 1")

        select("Current")
        click_button "see"

        expect(page).not_to have_content("quote for version 1")
        expect(page).to have_content("quote for version 2")
      end

      scenario "with js" do
        visit legislation_process_draft_version_annotations_path(process, original)
        expect(page).to have_content("quote for version 1")

        select("Current")

        expect(page).not_to have_content("quote for version 1")
        expect(page).to have_content("quote for version 2")
      end
    end
  end

  context "Annotation comments page" do
    let(:draft_version) { create(:legislation_draft_version, :published) }

    before do
      create(:legislation_annotation,
             draft_version: draft_version,
             text: "my annotation",
             quote: "ipsum",
             ranges: [{ "start" => "/p[1]", "startOffset" => 6, "end" => "/p[1]", "endOffset" => 11 }])
    end

    scenario "See one annotation with replies for a draft version" do
      annotation = create(:legislation_annotation,
                          draft_version: draft_version,
                          text: "my other annotation",
                          quote: "audiam",
                          ranges: [{ "start" => "/p[3]",
                                     "startOffset" => 6,
                                     "end" => "/p[3]",
                                     "endOffset" => 11 }])

      visit polymorphic_path(annotation)

      expect(page).not_to have_content "ipsum"
      expect(page).not_to have_content "my annotation"

      expect(page).to have_content "audiam"
      expect(page).to have_content "my other annotation"
    end
  end

  context "See table from markdown" do
    let(:draft_version) { create(:legislation_draft_version, :published, :with_table) }
    let(:path) do
      edit_admin_legislation_process_draft_version_path(draft_version.process, draft_version)
    end

    scenario "See table as a user" do
      visit legislation_process_draft_version_path(draft_version.process, draft_version)

      expect(page).to have_table
      expect(page).to have_content "Roberta"
      expect(page).to have_content "25"
    end

    scenario "See table as an admin" do
      login_as(administrator)

      visit path
      click_link "Launch text editor"

      expect(page).to have_table
      expect(page).to have_content "Roberta"
      expect(page).to have_content "25"
    end
  end
end
