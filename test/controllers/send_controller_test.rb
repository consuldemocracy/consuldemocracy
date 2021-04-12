require 'test_helper'

class SendControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get send_index_url
    assert_response :success
  end

end
