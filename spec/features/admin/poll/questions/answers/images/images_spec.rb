require 'rails_helper'

describe 'Images' do

  before do
    admin = create(:administrator)
    login_as(admin.user)
  end

  pending "Index"
  pending "Create"
  pending "Destroy"

end