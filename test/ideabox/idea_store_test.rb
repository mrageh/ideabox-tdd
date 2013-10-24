ENV['RACK_ENV'] = 'test'

require "./test/test_helper.rb"
require './lib/ideabox/idea'
require './lib/ideabox/idea_store'

class IdeaStoreTest < Minitest::Test
  def teardown
    IdeaStore.delete_all
  end

  def test_save_and_retrieve_an_idea
    idea = Idea.new({"id" => "0", "title" => "celebrate", "description" => "with champagne"})
    id = IdeaStore.save(idea)

    assert_equal 1, IdeaStore.count

    idea = IdeaStore.find(id)
    assert_equal "celebrate", idea.title
    assert_equal "with champagne", idea.description
  end

  def test_it_counts
    assert_equal 0, IdeaStore.count
    idea = Idea.new({"id" => "0", "title" => "celebrate", "description" => "with champagne"})
    idea2 = Idea.new({"id" => "2", "title" => "celebrate", "description" => "with champagne"})
    id = IdeaStore.save(idea)
    id2 = IdeaStore.save(idea2)
    assert_equal 2, IdeaStore.count
  end

  def test_stores_data_in_database
    idea = Idea.new({"id" => "0", "title" => "celebrate", "description" => "with champagne"})
    id = IdeaStore.save(idea)
    assert_equal 0, IdeaStore.find(id).id
  end

  def test_save_and_retrieve_one_of_many
    idea1 = Idea.new("title" =>"relax", "description" => "in the sauna")
    idea2 = Idea.new("title" => "inspiration","description" => "looking at the stars", "tag" => 'testing')
    idea3 = Idea.new("title" =>  "career", "description" => "translate for the UN")
    id1 = IdeaStore.save(idea1)
    id2 = IdeaStore.save(idea2)
    id3 = IdeaStore.save(idea3)

    assert_equal 3, IdeaStore.count

    idea = IdeaStore.find(id2)
    assert_equal "inspiration", idea.title
    assert_equal "looking at the stars", idea.description
  end

  def test_find_by_title
    dance = Idea.new("id" => '1', "title" => "dance","description"=> "like it's the 80s")
    sleep = Idea.new("id" => '2', "title" => "sleep","description"=> "like a baby")
    dream = Idea.new("id" => '3', "title" => "dream","description"=> "like anything is possible")
    IdeaStore.save(dance)
    IdeaStore.save(sleep)
    IdeaStore.save(dream)

    idea = IdeaStore.find_by_title('sleep')
    assert_equal 'like a baby', idea.description
  end

  def test_find_by_tag
    dance = Idea.new("id" => '1', "title" => "dance","description"=> "like it's the 80s", 'tag' => 'funny')
    sleep = Idea.new("id" => '2', "title" => "sleep","description"=> "like a baby", 'tag' => 'funny')
    dream = Idea.new("id" => '3', "title" => "dream","description"=> "like anything is possible")
    IdeaStore.save(dance)
    IdeaStore.save(sleep)
    IdeaStore.save(dream)

    idea = IdeaStore.find_by_tag('funny')
    assert_equal 'funny', idea.first.tag
    assert_equal 2, idea.count
  end

  def test_sort_by_tags
    dance  = Idea.new("title" => "dance","description"=> "like it's the 80s", 'tag' => 'funny')
    sleep  = Idea.new("title" => "sleep","description"=> "like a baby", 'tag' => 'amazing')
    dream  = Idea.new("title" => "dream","description"=> "like anything is possible", 'tag' => 'no way')
    tomato = Idea.new("title" => "drink","description" => "tomato juice")
    IdeaStore.save(dance)
    IdeaStore.save(sleep)
    IdeaStore.save(dream)
    IdeaStore.save(tomato)
    idea = IdeaStore.sorted_by_tags
    assert_equal 4, idea.count
    assert_equal 'amazing', idea.first.tag
    assert_equal 'funny', idea[1].tag
  end

  def test_update_idea
    idea = Idea.new("title" => "drink","description" => "tomato juice")
    id = IdeaStore.save(idea)

    idea = IdeaStore.find(id)
    idea.title = "cocktails"
    idea.description = "spicy tomato juice with vodka"

    IdeaStore.save(idea)
    assert_equal 1, IdeaStore.count

    idea = IdeaStore.find(id)
    assert_equal "cocktails", idea.title
    assert_equal "spicy tomato juice with vodka", idea.description
  end

  def test_delete_an_idea
    id1 = IdeaStore.save Idea.new("id" => "0","title" => "song", "description" => "99 bottles of beer")
    id2 = IdeaStore.save Idea.new("id" => "1", "title" => "gift", "description" => "micky mouse belt")
    id3 = IdeaStore.save Idea.new("id" => "2","title" => "dinner","description" => "cheeseburger with bacon and avocado")

    assert_equal ["song", "gift", "dinner"], IdeaStore.all.map(&:title)
    IdeaStore.delete(id2)
    assert_equal ["song", "dinner"], IdeaStore.all.map(&:title)
  end
end
