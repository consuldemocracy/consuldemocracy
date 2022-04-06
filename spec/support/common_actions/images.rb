module Images
  def imageable_redirected_to_resource_show_or_navigate_to(imageable)
    case imageable.class.to_s
    when "Budget"
      visit edit_admin_budget_path(Budget.last)
    when "Proposal"
      click_on "Not now, go to my proposal" rescue Capybara::ElementNotFound
    end
  end

  def imageable_attach_new_file(path, success = true)
    click_link "Add image"
    within "#nested-image" do
      image = find(".image")
      attach_file "Choose image", path
      within image do
        if success
          expect(page).to have_css(".loading-bar.complete")
        else
          expect(page).to have_css(".loading-bar.errors")
        end
      end
    end
  end

  def imageable_fill_new_valid_proposal
    fill_in_new_proposal_title with: "Proposal title"
    fill_in "Proposal summary", with: "Proposal summary"
    check :proposal_terms_of_service
  end

  def imageable_fill_new_valid_budget
    fill_in "Name", with: "Budget name"
  end

  def imageable_fill_new_valid_budget_investment
    fill_in_new_investment_title with: "Budget investment title"
    fill_in_ckeditor "Description", with: "Budget investment description"
    check :budget_investment_terms_of_service
  end

  def expect_image_has_title(title)
    image = find(".image")

    within image do
      expect(find("input[name$='[title]']").value).to eq title
    end
  end

  def show_caption_for?(imageable_factory_name)
    imageable_factory_name != "budget"
  end
end
