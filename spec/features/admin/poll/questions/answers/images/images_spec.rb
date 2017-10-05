require 'rails_helper'

feature 'Images' do

  background do
    admin = create(:administrator)
    login_as(admin.user)
  end

  pending "Index"
  pending "Create"
  pending "Destroy"

end