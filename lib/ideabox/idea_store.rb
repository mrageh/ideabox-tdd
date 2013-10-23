class IdeaStore

  # def self.database
  #   return @database if @database

  #   @database ||= YAML::Store.new("db/ideabox")
  #   @database.transaction do
  #     @database['ideas'] ||= []
  #   end
  #   @database
  # end

  # def database
  #   Idea.database
  # end

  def self.all
    @all ||= []
  end

  def self.save(idea)
    idea.id ||= next_id
    all[idea.id] = idea
    idea.id
  end

  def self.find(id)
    all[id]
  end

  def self.find_by_title(title)
    all.find do |idea|
      idea.title == title
    end
  end

  def self.next_id
    all.size
  end

  def self.count
    all.length
  end

  def self.delete(id)
    all.delete_at(id)
  end

  def self.delete_all
    @all =[]
  end
end
