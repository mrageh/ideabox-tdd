ENV['RACK_ENV'] = 'test'
require "./test/test_helper"
require "bundler"
Bundler.require
require "rack/test"
require "capybara"
require "capybara/dsl"
require "pry"
require "./lib/app"

Capybara.app = IdeaboxApp

Capybara.register_driver :rack_test do |app|
  Capybara::RackTest::Driver.new(app, :headers => { 'User-Agent' => 'Capybara' })
end

class IdeaManagementTest < Minitest::Test
  include Capybara::DSL

  def teardown
    IdeaStore.delete_all
  end

  def test_manage_ideas
    #Create a two decoys
    #So we know this is what we are editing
    dinner = Idea.new("title" => "dinner","description" => "spaghetti and meatballs", "tag" => "testing")
    drinks = Idea.new("title" => "drinks", "description" => "imported beers", "tag" => "wooow")
    IdeaStore.save(dinner)
    IdeaStore.save(drinks)

    #Create an idea
    visit '/'

    #Make sure decoys are there
    assert page.has_content?("spaghetti and meatballs")
    assert page.has_content?("imported beers")

    #Fill in the form
    fill_in 'title', :with => 'eat'
    fill_in 'description', :with => 'chocolate chip cookies'
    fill_in 'tag', :with => 'yummy'
    click_button 'Save'
    assert page.has_content?("chocolate chip cookies"), "Idea is not on page"

    #Find the idea, we need the ID to
    #find it on the page to edit
    idea = IdeaStore.find_by_title('eat')

    #Edit an idea
    within("#idea_#{idea.id}") do
      click_link 'Edit'
    end

    assert_equal 'eat', find_field('title').value
    assert_equal "chocolate chip cookies", find_field('description').value
    assert_equal 'yummy', find_field('tag').value

    fill_in 'title', :with => 'maybe later'
    fill_in 'description', :with => 'I will eat my food after my meeting'
    fill_in 'tag', :with => 'food'

    click_button 'Save'

    #Check idea has been updated
    assert page.has_content?("I will eat my food after my meeting"), "Updated idea is not on page"


    #Check Decoys are still unchanged
    assert page.has_content?("spaghetti and meatballs"), "Decoy idea (dinner) is not on page"
    assert page.has_content?("imported beers"), "Decoy idea (drinks) is not on page"


    #Check if original idea that got edited is not there
    refute page.has_content?("chocolate chip cookies"), "Original idea is on page still"

    # Delete the idea
    within("#idea_#{idea.id}") do
      click_button 'Delete'
    end

    refute page.has_content?("I will eat my food after my meeting"), "Updated idea is not on page"


    #Decoys are untouched
    assert page.has_content?("spaghetti and meatballs"), "Decoy idea (dinner) is not on page"
    assert page.has_content?("imported beers"), "Decoy idea (drinks) is not on page"
  end

  def test_ranking_ideas
     #Because this shitty test fails!!!!!
     #Finally found out why its failing
     #I was trying to use put instead of
     #Post even though put is used to update as well!!!!!!
    id1 = IdeaStore.save Idea.new("title" => "fun", "description" => "ride horses")
    id2 = IdeaStore.save Idea.new("title" => "vacation", "description" => "camping in the mountains")
    id3 = IdeaStore.save Idea.new("title" => "write", "description" => "a book about being brave")

    visit '/'

    idea = IdeaStore.find(id2) #My rank is not being incremented when we call a object stored in all?
    idea.like!                 #If we call like! on just a idea the rank is incremented??
    idea.like!                 #Could it be because of the way my all method works? No
    idea.like!                 #It is now very clear that the rank is incremented in development db
    idea.like!                 #But it is not incremented here in the test db?? very strange!!
    idea.like!
    IdeaStore.save(idea)

    within("#idea_#{id2}") do
      3.times do
        click_button '+'
      end
    end

    within("#idea_#{id3}") do
      click_button '+'
    end

    # now check that the order is correct
    ideas_on_page = page.all('li')
    assert_match /camping in the mountains/, ideas_on_page[0].text
    assert_match /a book about being brave/, ideas_on_page[1].text
    assert_match /ride horses/, ideas_on_page[2].text
  end
end
