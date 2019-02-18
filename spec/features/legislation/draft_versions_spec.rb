require "rails_helper"

feature "Legislation Draft Versions" do
  let(:user) { create(:user) }
  let(:administrator) do
    create(:administrator, user: user)
    user
  end

  context "See draft text page" do
    before do
      @process = create(:legislation_process)
      @draft_version_1 = create(:legislation_draft_version, process: @process, title: "Version 1",
                                                            body: "Body of the first version", status: "published")
      @draft_version_2 = create(:legislation_draft_version, process: @process, title: "Version 2",
                                                            body: "Body of the second version", status: "published")
      @draft_version_3 = create(:legislation_draft_version, process: @process, title: "Version 3",
                                                            body: "Body of the third version", status: "draft")
    end

    it "shows the text body for this version" do
      visit legislation_process_draft_version_path(@process, @draft_version_1)

      expect(page).to have_content("Body of the first version")

      within("select#draft_version_id") do
        expect(page).to have_content("Version 1")
        expect(page).to have_content("Version 2")
        expect(page).not_to have_content("Version 3")
      end
    end

    it "shows an unpublished version to admins" do
      login_as(administrator)

      visit legislation_process_draft_version_path(@process, @draft_version_3)

      expect(page).to have_content("Body of the third version")

      within("select#draft_version_id") do
        expect(page).to have_content("Version 1")
        expect(page).to have_content("Version 2")
        expect(page).to have_content("Version 3 *")
      end
    end

    it "switches to another version without js" do
      visit legislation_process_draft_version_path(@process, @draft_version_1)
      expect(page).to have_content("Body of the first version")

      select("Version 2")
      click_button "see"

      expect(page).not_to have_content("Body of the first version")
      expect(page).to have_content("Body of the second version")
    end

    it "switches to another version with js", :js do
      visit legislation_process_draft_version_path(@process, @draft_version_1)
      expect(page).to have_content("Body of the first version")

      select("Version 2")

      expect(page).not_to have_content("Body of the first version")
      expect(page).to have_content("Body of the second version")
    end

    context "for final versions" do
      it "does not show the comments panel" do
        final_version = create(:legislation_draft_version, process: @process, title: "Final version",
                                                           body: "Final body", status: "published", final_version: true)

        visit legislation_process_draft_version_path(@process, final_version)

        expect(page).to have_content("Final body")
        expect(page).not_to have_content("See all comments")
        within(".draft-panels") do
          expect(page).not_to have_content("Comments")
        end
      end
    end
  end

  context "See changes page" do
    before do
      @process = create(:legislation_process)
      @draft_version_1 = create(:legislation_draft_version, process: @process, title: "Version 1", body: "Body of the first version",
                                                            changelog: "Changes for first version", status: "published")
      @draft_version_2 = create(:legislation_draft_version, process: @process, title: "Version 2", body: "Body of the second version",
                                                            changelog: "Changes for second version", status: "published")
      @draft_version_3 = create(:legislation_draft_version, process: @process, title: "Version 3", body: "Body of the third version",
                                                            changelog: "Changes for third version", status: "draft")
    end

    it "shows the changes for this version" do
      visit legislation_process_draft_version_changes_path(@process, @draft_version_1)

      expect(page).to have_content("Changes for first version")

      within("select#draft_version_id") do
        expect(page).to have_content("Version 1")
        expect(page).to have_content("Version 2")
        expect(page).not_to have_content("Version 3")
      end
    end

    it "shows an unpublished version to admins" do
      login_as(administrator)

      visit legislation_process_draft_version_changes_path(@process, @draft_version_3)

      expect(page).to have_content("Changes for third version")

      within("select#draft_version_id") do
        expect(page).to have_content("Version 1")
        expect(page).to have_content("Version 2")
        expect(page).to have_content("Version 3 *")
      end
    end

    it "switches to another version without js" do
      visit legislation_process_draft_version_changes_path(@process, @draft_version_1)
      expect(page).to have_content("Changes for first version")

      select("Version 2")
      click_button "see"

      expect(page).not_to have_content("Changes for first version")
      expect(page).to have_content("Changes for second version")
    end

    it "switches to another version with js", :js do
      visit legislation_process_draft_version_changes_path(@process, @draft_version_1)
      expect(page).to have_content("Changes for first version")

      select("Version 2")

      expect(page).not_to have_content("Changes for first version")
      expect(page).to have_content("Changes for second version")
    end
  end

  context "Annotations", :js do
    let(:user) { create(:user) }

    background { login_as user }

    scenario "Visit as anonymous" do
      logout
      draft_version = create(:legislation_draft_version, :published)

      visit legislation_process_draft_version_path(draft_version.process, draft_version)

      page.find(:css, ".legislation-annotatable").double_click
      page.find(:css, ".annotator-adder button").click
      expect(page).not_to have_css("#legislation_annotation_text")
      expect(page).to have_content "You must Sign in or Sign up to leave a comment."
    end

    scenario "Create" do
      draft_version = create(:legislation_draft_version, :published)

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
      draft_version = create(:legislation_draft_version, :published)
      annotation1 = create(:legislation_annotation, draft_version: draft_version, text: "my annotation",
                                                    ranges: [{"start" => "/p[1]", "startOffset" => 5, "end" => "/p[1]", "endOffset" => 10}])
      create(:legislation_annotation, draft_version: draft_version, text: "my other annotation",
                                      ranges: [{"start" => "/p[1]", "startOffset" => 12, "end" => "/p[1]", "endOffset" => 19}])
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
      draft_version = create(:legislation_draft_version, :published)
      annotation = create(:legislation_annotation, draft_version: draft_version, text: "my annotation",
                                                   ranges: [{"start" => "/p[1]", "startOffset" => 6, "end" => "/p[1]", "endOffset" => 11}])

      visit legislation_process_draft_version_path(draft_version.process, draft_version)

      expect(page).to have_css ".annotator-hl"
      first(:css, ".annotator-hl").click
      expect(page).to have_content "my annotation"

      click_link "Publish Comment"
      fill_in "comment[body]", with: "My interesting comment"
      click_button "Publish comment"
      expect(page).to have_content "My interesting comment"
    end
  end

  context "Merged annotations", :js do

    let(:user) { create(:user) }

    background { login_as user }

    scenario "View annotations and comments in an included range" do
      draft_version = create(:legislation_draft_version, :published)
      annotation1 = create(:legislation_annotation, draft_version: draft_version, text: "my annotation",
                                                    ranges: [{"start" => "/p[1]", "startOffset" => 1, "end" => "/p[1]", "endOffset" => 5}])
      annotation2 = create(:legislation_annotation, draft_version: draft_version, text: "my other annotation",
                                                    ranges: [{"start" => "/p[1]", "startOffset" => 1, "end" => "/p[1]", "endOffset" => 10}])

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
    background do
      @draft_version = create(:legislation_draft_version, :published)
      create(:legislation_annotation, draft_version: @draft_version, text: "my annotation",       quote: "ipsum",
                                      ranges: [{"start" => "/p[1]", "startOffset" => 6, "end" => "/p[1]", "endOffset" => 11}])
      create(:legislation_annotation, draft_version: @draft_version, text: "my other annotation", quote: "audiam",
                                      ranges: [{"start" => "/p[3]", "startOffset" => 6, "end" => "/p[3]", "endOffset" => 11}])
    end

    scenario "See all annotations for a draft version" do
      visit legislation_process_draft_version_annotations_path(@draft_version.process, @draft_version)

      expect(page).to have_content "ipsum"
      expect(page).to have_content "audiam"
    end

    context "switching versions" do
      background do
        @process = create(:legislation_process)
        @draft_version_1 = create(:legislation_draft_version, :published, process: @process,
                                                                          title: "Version 1", body: "Text with quote for version 1")
        create(:legislation_annotation, draft_version: @draft_version_1, text: "annotation for version 1", quote: "quote for version 1",
                                        ranges: [{"start" => "/p[1]", "startOffset" => 11, "end" => "/p[1]", "endOffset" => 30}])
        @draft_version_2 = create(:legislation_draft_version, :published, process: @process,
                                                                          title: "Version 2", body: "Text with quote for version 2")
        create(:legislation_annotation, draft_version: @draft_version_2, text: "annotation for version 2", quote: "quote for version 2",
                                        ranges: [{"start" => "/p[1]", "startOffset" => 11, "end" => "/p[1]", "endOffset" => 30}])
      end

      scenario "without js" do
        visit legislation_process_draft_version_annotations_path(@process, @draft_version_1)
        expect(page).to have_content("quote for version 1")

        select("Version 2")
        click_button "see"

        expect(page).not_to have_content("quote for version 1")
        expect(page).to have_content("quote for version 2")
      end

      scenario "with js", :js do
        visit legislation_process_draft_version_annotations_path(@process, @draft_version_1)
        expect(page).to have_content("quote for version 1")

        select("Version 2")

        expect(page).not_to have_content("quote for version 1")
        expect(page).to have_content("quote for version 2")
      end
    end
  end

  context "Annotation comments page" do
    background do
      @draft_version = create(:legislation_draft_version, :published)
      create(:legislation_annotation, draft_version: @draft_version, text: "my annotation", quote: "ipsum",
                                      ranges: [{"start" => "/p[1]", "startOffset" => 6, "end" => "/p[1]", "endOffset" => 11}])
      @annotation = create(:legislation_annotation, draft_version: @draft_version, text: "my other annotation", quote: "audiam",
                                                    ranges: [{"start" => "/p[3]", "startOffset" => 6, "end" => "/p[3]", "endOffset" => 11}])
    end

    scenario "See one annotation with replies for a draft version" do
      visit legislation_process_draft_version_annotation_path(@draft_version.process, @draft_version, @annotation)

      expect(page).not_to have_content "ipsum"
      expect(page).not_to have_content "my annotation"

      expect(page).to have_content "audiam"
      expect(page).to have_content "my other annotation"
    end
  end

end
