ENV['RACK_ENV'] = 'test'

require './app'
require 'test/unit'
require 'rack/test'
require "simplecov"
SimpleCov.start

class AppTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def teardown
    Doctor.destroy_all
  end

  def test_it_returns_empty_doctors_with_default_headers
    response = {
      'doctors' => []
    }
    headers = {
      content_range: {
        'field' => 'id',
        'start' => nil,
        'end' => nil
      }
    }
    get '/doctors'
    assert last_response.ok?
    assert_equal response, JSON.parse(last_response.body)
    assert_equal headers[:content_range],  JSON.parse(last_response.headers['Content-Range'])
    assert_equal nil, last_response.headers['Next-Range']
  end

  def test_it_returns_doctors_with_field_name
    5.times do |i|
      Doctor.create( name: "fancy name #{i}")
    end
    response = {
      'doctors' => Doctor.
                    where("name >= 'fancy name 1'").
                    order(name: :asc).limit(3).map(&:to_json)
    }
    headers = {
      content_range: {
        'field' => 'name',
        'start' => 'fancy name 1',
        'end' => 'fancy name 3'
      },
      next_range: {
        'field' => 'name',
        'start' => 'fancy name 3',
        'max' => 3
      }
    }
    header 'Range', {field: 'name', max: 3, start: "fancy name 1"}.to_json
    get '/doctors'
    assert last_response.ok?
    assert_equal response, JSON.parse(last_response.body)
    assert_equal headers[:content_range],  JSON.parse(last_response.headers['Content-Range'])
    assert_equal headers[:next_range], JSON.parse(last_response.headers['Next-Range'])
  end

  def test_it_returns_doctors_with_desc_order
    5.times do |i|
      Doctor.create( name: "fancy name #{i}")
    end
    response = {
      'doctors' => Doctor.
                    order(name: :desc).limit(3).map(&:to_json)
    }
    headers = {
      content_range: {
        'field' => 'name',
        'start' => 'fancy name 4',
        'end' => 'fancy name 2'
      },
      next_range: {
        'field' => 'name',
        'start' => 'fancy name 2',
        'max' => 3
      }
    }
    header 'Range', {field: 'name', max: 3, order: 'desc'}.to_json
    get '/doctors'
    assert last_response.ok?
    assert_equal response, JSON.parse(last_response.body)
    assert_equal headers[:content_range],  JSON.parse(last_response.headers['Content-Range'])
    assert_equal headers[:next_range], JSON.parse(last_response.headers['Next-Range'])
  end
end
