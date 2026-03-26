require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    sign_in_as(User.take)
    # get dashboard_url
    # assert_response :success
  end
end
