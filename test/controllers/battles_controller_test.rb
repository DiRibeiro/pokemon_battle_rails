require "test_helper"

class BattlesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    # get battles_index_url
    get root_url
    assert_response :success
  end
end
