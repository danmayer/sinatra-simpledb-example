require 'sinatra-simpledb'
require 'test/unit'
require 'rack/test'

set :environment, :test

class SinatraSimpleDBTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_front_page_says_view_posts
    get '/'
    assert last_response.ok?
    assert last_response.body.include?('view posts:')
  end

  def test_creates_a_post
    get '/create', :title => 'Simon'
    assert last_response.body.include?('article created ->')
    assert last_response.body.include?('Simon')
  end

  def test_deletes_a_post
    get '/create', :title => 'Delete Me', :id => 333
    assert last_response.body.include?('article created ->')
    assert last_response.body.include?('Delete Me')
    sleep(1.5) #eventual consitancy on SDB takes time
    get '/delete', :id => '333'
    get '/'
    assert last_response.ok?
    assert !last_response.body.include?('Delete Me')
  end

end
