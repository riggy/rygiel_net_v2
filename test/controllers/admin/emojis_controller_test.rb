require "test_helper"

class Admin::EmojisControllerTest < ActionDispatch::IntegrationTest
  setup do
    @credentials = ActionController::HttpAuthentication::Basic.encode_credentials("admin", "admin")
  end

  test "returns JSON object mapping emoji names to unicode characters" do
    get "/admin/emojis.json", headers: { "Authorization" => @credentials }

    assert_response :success
    assert_equal "application/json", response.content_type.split(";").first

    data = JSON.parse(response.body)
    assert_instance_of Hash, data
    assert data.key?("smile"), "expected 'smile' emoji to be present"
    assert_match(/\p{Emoji}/, data["smile"])
  end

  test "returns multiple aliases for the same emoji" do
    get "/admin/emojis.json", headers: { "Authorization" => @credentials }

    data = JSON.parse(response.body)
    # +1 and :+1: are both aliases for the thumbs-up emoji
    assert data.key?("+1"), "expected '+1' alias to be present"
    assert data.key?("thumbsup"), "expected 'thumbsup' alias to be present"
    assert_equal data["+1"], data["thumbsup"]
  end

  test "requires authentication" do
    get "/admin/emojis.json"

    assert_response :unauthorized
  end
end
