require 'test_helper'

class PhoneContactControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get phone_contact_index_url
    assert_response :success
  end

end
