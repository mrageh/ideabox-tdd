require "./test/test_helper.rb"
require './lib/ideabox/idea'
require './lib/ideabox/idea_store'

class IdeaStoreTest < Minitest::Test
  def teardown
    IdeaStore.delete_all
  end

  def test_save_and_retrieve_an_idea
    idea = Idea.new("celebrate", "with champagne")
    id = IdeaStore.save(idea)

    assert_equal 1, IdeaStore.count

    idea = IdeaStore.find(id)
    assert_equal "celebrate", idea.title
    assert_equal "with champagne", idea.description
  end

  def test_save_and_retrieve_one_of_many
    idea1 = Idea.new("relax", "in the sauna")
    idea2 = Idea.new("inspiration", "looking at the stars")
    idea3 = Idea.new("career", "translate for the UN")
    id1 = IdeaStore.save(idea1)
    id2 = IdeaStore.save(idea2)
    id3 = IdeaStore.save(idea3)

    assert_equal 3, IdeaStore.count

    idea = IdeaStore.find(id2)
    assert_equal "inspiration", idea.title
    assert_equal "looking at the stars", idea.description
  end

  def test_find_by_title
    dance = Idea.new("dance", "like it's the 80s")
    sleep = Idea.new("sleep", "like a baby")
    dream = Idea.new("dream", "like anything is possible")
    IdeaStore.save(dance)
    IdeaStore.save(sleep)
    IdeaStore.save(dream)

    idea = IdeaStore.find_by_title('sleep')
    assert_equal 'like a baby', idea.description
  end

  def test_update_idea
    idea = Idea.new("drink", "tomato juice")
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
    id1 = IdeaStore.save Idea.new("song", "99 bottles of beer")
    id2 = IdeaStore.save Idea.new("gift", "micky mouse belt")
    id3 = IdeaStore.save Idea.new("dinner", "cheeseburger with bacon and avocado")

    assert_equal ["song", "gift", "dinner"], IdeaStore.all.map(&:title)
    IdeaStore.delete(id2)
    assert_equal ["song", "dinner"], IdeaStore.all.map(&:title)
  end
end
