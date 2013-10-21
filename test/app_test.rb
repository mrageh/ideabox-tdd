require './test/test_helper'
require 'sinatra/base'
require 'rack/test'
require './lib/app'

class IdeaboxAppHelper < Minitest::Test
  include Rack::Test::Methods

  def teardown
    IdeaStore.delete_all
  end

  def app
    IdeaboxApp
  end

  def test_idea_list
    dinner = Idea.new("dinner", "spaghetti and meatballs")
    drinks = Idea.new("drinks", "imported beers")
    movie  = Idea.new("movie", "The Matrix")
    IdeaStore.save(dinner)
    IdeaStore.save(drinks)
    IdeaStore.save(movie)
    get '/'
    [
      /dinner/, /spaghetti/,
      /drinks/, /imported beers/, #Can you help me visualize this?
      /movie/, /The Matrix/
    ].each do |content|
       assert_match content, last_response.body
     end
  end

end
