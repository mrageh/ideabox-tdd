require "./test/test_helper"
require "bundler"
Bundler.require
require "rack/test"
require "capybara"
require "capybara/dsl"

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
    eat = Idea.new("eat", "chocolate chip cookies")
    IdeaStore.save(eat)
    visit '/'
    assert page.has_content?("chocolate chip cookies")
  end
end
