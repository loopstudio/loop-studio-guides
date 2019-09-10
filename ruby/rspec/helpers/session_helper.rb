module SessionHelper
  def json
    JSON.parse(response.body).with_indifferent_access
  end

  def auth_headers(some_user = user)
    @auth_headers ||= some_user.create_new_auth_token
  end

  def test_picture
    path = File.join(Rails.root, 'spec', 'support', 'fixtures', 'sample_graph.png')
    Rack::Test::UploadedFile.new(path, 'image/png')
  end
end
