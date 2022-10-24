shared_examples "admin_progressable" do |factory_name, path_name|
  let!(:progressable) { create(factory_name) }

  describe "Manage progress bars" do
    let(:progressable_path) { send(path_name, progressable) }

    let(:path) do
      admin_polymorphic_path(progressable.progress_bars.new)
    end

    context "Index" do
      scenario "Link to index path" do
        create(:progress_bar, :secondary, progressable:  progressable,
               title:      "Reading documents",
               percentage: 20)

        visit progressable_path
        click_link "Manage progress bars"

        expect(page).to have_content "Reading documents"
      end

      scenario "No progress bars" do
        visit path

        expect(page).to have_content("There are no progress bars")
      end
    end

    context "New" do
      scenario "Primary progress bar" do
        visit path
        click_link "Create new progress bar"

        select "Primary", from: "Type"

        expect(page).not_to have_field "Title"
        expect(page).not_to have_content "Add language"

        fill_in "Current progress", with: 43
        click_button "Create Progress bar"

        expect(page).to have_content "Progress bar created successfully"
        expect(page).to have_content "43%"
        expect(page).to have_content "Primary"
        expect(page).to have_content "Primary progress bar"
      end

      scenario "Secondary progress bar" do
        visit path
        click_link "Create new progress bar"

        select "Secondary", from: "Type"

        expect(page).to have_content "Add language"

        fill_in "Current progress", with: 36
        fill_in "Title", with: "Plant trees"
        click_button "Create Progress bar"

        expect(page).to have_content "Progress bar created successfully"
        expect(page).to have_content "36%"
        expect(page).to have_content "Secondary"
        expect(page).to have_content "Plant trees"
      end
    end

    context "Edit" do
      scenario "Primary progress bar" do
        bar = create(:progress_bar, progressable: progressable)

        visit path
        within("#progress_bar_#{bar.id}") { click_link "Edit" }

        expect(page).to have_field "Current progress"
        expect(page).not_to have_field "Title"
        expect(page).not_to have_content "Add language"

        fill_in "Current progress", with: 44
        click_button "Update Progress bar"

        expect(page).to have_content "Progress bar updated successfully"

        within("#progress_bar_#{bar.id}") do
          expect(page).to have_content "44%"
        end
      end

      scenario "Secondary progress bar" do
        bar = create(:progress_bar, :secondary, progressable: progressable)

        visit path
        within("#progress_bar_#{bar.id}") { click_link "Edit" }

        expect(page).to have_content "Add language"

        fill_in "Current progress", with: 76
        fill_in "Title", with: "Updated title"
        click_button "Update Progress bar"

        expect(page).to have_content "Progress bar updated successfully"

        within("#progress_bar_#{bar.id}") do
          expect(page).to have_content "76%"
          expect(page).to have_content "Updated title"
        end
      end
    end

    context "Delete" do
      scenario "Remove progress bar" do
        bar = create(:progress_bar, progressable: progressable, percentage: 34)

        visit path
        within("#progress_bar_#{bar.id}") { accept_confirm { click_button "Delete" } }

        expect(page).to have_content "Progress bar deleted successfully"
        expect(page).not_to have_content "34%"
      end
    end
  end
end
