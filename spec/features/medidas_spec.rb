feature 'Admin medidas' do

  background do
    admin = create(:administrator)
    login_as(admin.user)
  end

  scenario 'Restore' do
    medida = create(:medida, :hidden)
    visit admin_medidas_path

    click_link 'Restore'

    expect(page).to_not have_content(medida.title)

    expect(medida.reload).to_not be_hidden
    expect(medida).to be_ignored_flag
  end

  scenario 'Confirm hide' do
    medida = create(:medida, :hidden)
    visit admin_medidas_path

    click_link 'Confirm'

    expect(page).to_not have_content(medida.title)
    click_link('Confirmed')
    expect(page).to have_content(medida.title)

    expect(medida.reload).to be_confirmed_hide
  end

  scenario "Current filter is properly highlighted" do
    visit admin_medidas_path
    expect(page).to_not have_link('Pending')
    expect(page).to have_link('All')
    expect(page).to have_link('Confirmed')

    visit admin_medidas_path(filter: 'Pending')
    expect(page).to_not have_link('Pending')
    expect(page).to have_link('All')
    expect(page).to have_link('Confirmed')

    visit admin_medidas_path(filter: 'all')
    expect(page).to have_link('Pending')
    expect(page).to_not have_link('All')
    expect(page).to have_link('Confirmed')

    visit admin_medidas_path(filter: 'with_confirmed_hide')
    expect(page).to have_link('All')
    expect(page).to have_link('Pending')
    expect(page).to_not have_link('Confirmed')
  end

  scenario "Filtering medidas" do
    create(:medida, :hidden, title: "Unconfirmed medida")
    create(:medida, :hidden, :with_confirmed_hide, title: "Confirmed medida")

    visit admin_medidas_path(filter: 'pending')
    expect(page).to have_content('Unconfirmed medida')
    expect(page).to_not have_content('Confirmed medida')

    visit admin_medidas_path(filter: 'all')
    expect(page).to have_content('Unconfirmed medida')
    expect(page).to have_content('Confirmed medida')

    visit admin_medidas_path(filter: 'with_confirmed_hide')
    expect(page).to_not have_content('Unconfirmed medida')
    expect(page).to have_content('Confirmed medida')
  end

  scenario "Action links remember the pagination setting and the filter" do
    per_page = Kaminari.config.default_per_page
    (per_page + 2).times { create(:medida, :hidden, :with_confirmed_hide) }

    visit admin_medidas_path(filter: 'with_confirmed_hide', page: 2)

    click_on('Restore', match: :first, exact: true)

    expect(current_url).to include('filter=with_confirmed_hide')
    expect(current_url).to include('page=2')
  end

end
