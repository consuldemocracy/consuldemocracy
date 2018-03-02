require 'rails_helper'

feature 'Admin probes' do

  background do
    @probe = Probe.create(codename: 'testprobe')
    @probe_option_1 = @probe.probe_options.create(code: 'A1' , name: 'Test Probe Option 1', probe_selections_count: 3)
    @probe_option_2 = @probe.probe_options.create(code: 'A2' , name: 'Test Probe Option II', probe_selections_count: 10)

    admin = create(:administrator)
    login_as(admin.user)
  end

  scenario 'Show votes' do
    visit admin_probes_path

    click_link 'Testprobe'

    expect(page).to have_content 'Votes (13)'
    within("#probe_option_#{@probe_option_1.id}") do
      expect(page).to have_content '3'
    end
    within("#probe_option_#{@probe_option_2.id}") do
      expect(page).to have_content '10'
    end
  end

end