ENV['RACK_ENV'] = 'test'

require './app'
require 'test/unit'
require 'rack/test'

class AppTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_it_returns_doctors_with_default_headers
    response = {
      'doctors' => [

      ]
    }
    headers = {
      
    }
    get '/doctors'
    assert last_response.ok?
    assert_equal response, last_response.body
    assert_equal response, last_response.header
  end

end
