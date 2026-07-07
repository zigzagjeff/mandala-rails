module ApiTestHelper
  def authorized_headers(user = users(:one))
    { "Authorization" => "Bearer #{user.api_token}" }
  end
end

ActiveSupport.on_load(:action_dispatch_integration_test) do
  include ApiTestHelper
end
