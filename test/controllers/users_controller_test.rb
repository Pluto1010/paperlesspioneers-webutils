require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get csv" do
    get users_csv_url
    assert_response :success
  end

end
