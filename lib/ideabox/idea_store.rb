require "yaml/store"

class IdeaStore
  class << self

    def all
      database.transaction do
        database['ideas'].map {|idea_hash| Idea.new(idea_hash) }
      end
    end

    def database
      @database ||= YAML::Store.new("db/ideabox_#{environment}")
    end

    def environment
      ENV['RACK_ENV'] || 'development'
    end

    def save(idea)
      idea.id    ||= next_id
      save_to_database(idea)
      idea.id
    end

    def save_to_database(idea)
      database.transaction do
        database['ideas'] ||= []
        found_idea = database['ideas'].find {|y_idea| y_idea['id'] == idea.id }
        database['ideas'].delete(found_idea) if found_idea
        database['ideas'] << {"id" => idea.id, "title" => idea.title, "description" => idea.description, "rank" => idea.rank, "tag" => idea.tag}
      end
    end

    def find(id)
      all.find {|idea| idea.id == id }
    end

    def find_by_title(title)
      all.find do |idea|
        idea.title == title
      end
    end

    def find_by_tag(tag)
      all.select do |idea|
        idea.tag == tag
      end
    end

    def sorted_by_tags
      all.sort_by{|idea| idea.tag}
    end

    def next_id
      all.size
    end

    def count
      all.length
    end

    def delete(id)
      database.transaction do
        database['ideas'].delete_if{|idea_hash| idea_hash['id'] == id}
      end
    end

    def delete_all
      database.transaction do
        database['ideas'].clear
      end
    end

  end
end
