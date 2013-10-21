require "./test/test_helper"
require "./lib/ideabox/idea"

class IdeaTest < Minitest::Test

  def test_basic_idea
    idea = Idea.new("title", "description")
    assert_equal "title", idea.title
    assert_equal "description", idea.description
  end

  def test_ideas_can_be_liked
    idea = Idea.new("diet", "carrots and cucumbers")
    assert_equal 0, idea.rank # guard clause
    idea.like!
    assert_equal 1, idea.rank
  end

  def test_ideas_can_be_liked_more_than_once
    idea = Idea.new("exercise", "stickfighting")
    assert_equal 0, idea.rank # guard clause
    5.times do
      idea.like!
    end
    assert_equal 5, idea.rank
  end

  def test_ideas_can_be_sorted_by_rank
    diet     = Idea.new("diet", "cabbage soup")
    exercise = Idea.new("exercise", "long distance running")
    drink    = Idea.new("drink", "carrot smoothy")

    exercise.like!
    exercise.like!
    drink.like!

    ideas = [diet, exercise, drink]

    assert_equal [diet, drink, exercise], ideas.sort
  end
end
