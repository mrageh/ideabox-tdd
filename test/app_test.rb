ENV['RACK_ENV'] = 'test'

require './test/test_helper'
require 'sinatra/base'
require 'rack/test'
require './lib/app'
require "pry"

class IdeaboxAppHelper < Minitest::Test
  include Rack::Test::Methods

  def teardown
    IdeaStore.delete_all
  end

  def app
    IdeaboxApp
  end

  def test_idea_list
    dinner = Idea.new("title" => "dinner","description" =>  "spaghetti and meatballs")
    drinks = Idea.new("title" => "drinks","description" =>  "imported beers")
    movie  = Idea.new("title" => "movie", "description" => "The Matrix")
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

  def test_create_idea
    post '/', title: 'custome', description: 'scary vampire', tag: 'testing'

    assert_equal 1, IdeaStore.count

    idea = IdeaStore.all.first
    assert_equal 'custome', idea.title
    assert_equal 'scary vampire', idea.description
    assert_equal 'testing', idea.tag
  end

  def test_edit_idea
    sing = Idea.new('title' => 'sing','description' => 'happy songs')
    id   = IdeaStore.save(sing)

    put "/#{id}", {title: 'yodle', description: 'joyful songs', tag: 'testing'}

    assert_equal 302, last_response.status

    idea = IdeaStore.find(id)
    assert_equal 'yodle', idea.title
    assert_equal 'joyful songs', idea.description
  end

  def test_delete_idea
    sing = Idea.new('title' => 'sing','description' => 'happy songs')
    id = IdeaStore.save(sing)

    assert_equal 1, IdeaStore.count

    delete "/#{id}"

    assert_equal 302, last_response.status
    assert_equal 0, IdeaStore.count
  end

  def test_like_idea
    sing = Idea.new('title' => 'sing','description' => 'happy songs')
    id = IdeaStore.save(sing)

    put "/#{id}/like"
    idea = IdeaStore.find(id)
    assert_equal 1, idea.rank

    5.times do
      put "/#{id}/like"
      idea = IdeaStore.find(id)
    end

    assert_equal 6, idea.rank
  end

end
