module Verifications
  # spec/features/management/users_spec.rb
  # spec/features/verification/residence_spec.rb
  def select_date(values, selector)
    selector = selector[:from]
    day, month, year = values.split("-")
    select day,   from: "#{selector}_3i"
    select month, from: "#{selector}_2i"
    select year,  from: "#{selector}_1i"
  end

  # spec/features/admin/stats_spec.rb
  # spec/features/officing/voters_spec.rb
  # spec/features/polls/polls_spec.rb
  # spec/features/polls/voter_spec.rb
  # spec/features/tracks_spec.rb
  # spec/features/verification/level_three_verification_spec.rb
  # spec/features/verification/level_two_verification_spec.rb
  def verify_residence
    select 'DNI', from: 'residence_document_type'
    fill_in 'residence_document_number', with: "12345678Z"
    select_date '31-December-1980', from: 'residence_date_of_birth'
    fill_in 'residence_postal_code', with: '28013'
    check 'residence_terms_of_service'

    click_button 'Verify residence'
    expect(page).to have_content 'Residence verified'
  end

  # spec/features/officing/voters_spec.rb
  # spec/features/polls/polls_spec.rb
  # spec/features/polls/voter_spec.rb
  def officing_verify_residence
    select 'DNI', from: 'residence_document_type'
    fill_in 'residence_document_number', with: "12345678Z"
    fill_in 'residence_year_of_birth', with: "1980"

    click_button 'Validate document'

    expect(page).to have_content 'Document verified with Census'
  end

  # spec/features/official_positions_spec.rb
  def expect_badge_for(resource_name, resource)
    within("##{resource_name}_#{resource.id}") do
      expect(page).to have_css ".label.round"
      expect(page).to have_content "Employee"
    end
  end

  # spec/features/official_positions_spec.rb
  def expect_no_badge_for(resource_name, resource)
    within("##{resource_name}_#{resource.id}") do
      expect(page).not_to have_css ".label.round"
      expect(page).not_to have_content "Employee"
    end
  end

  # spec/features/tags/budget_investments_spec.rb
  # spec/features/tags/proposals_spec.rb
  # spec/shared/features/mappable.rb
  # spec/shared/features/nested_documentable.rb
  # spec/shared/features/nested_imageable.rb
  # Used to fill ckeditor fields
  # @param [String] locator label text for the textarea or textarea id
  def fill_in_ckeditor(locator, params = {})
    # Find out ckeditor id at runtime using its label
    locator = find('label', text: locator)[:for] if page.has_css?('label', text: locator)
    # Fill the editor content
    page.execute_script <<-SCRIPT
        var ckeditor = CKEDITOR.instances.#{locator}
        ckeditor.setData('#{params[:with]}')
        ckeditor.focus()
        ckeditor.updateElement()
    SCRIPT
  end
end
