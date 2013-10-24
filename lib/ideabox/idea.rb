class Idea
  include Comparable

  attr_accessor :id, :title, :description, :rank, :tag

  def initialize(params)
    @title       = params["title"]
    @description = params["description"]
    @rank        = params["rank"] || 0
    @id          = params["id"].to_i unless params["id"].nil?
    @tag         = params["tag"] || "other"
  end

  def like!
    @rank += 1
  end

  def <=>(other)
    rank <=> other.rank
  end

end
