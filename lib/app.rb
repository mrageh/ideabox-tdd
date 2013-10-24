require './lib/ideabox'

class IdeaboxApp < Sinatra::Base
  set :method_override, true
  set :root, "./lib/app"

  post '/' do
    idea = Idea.new({'title' => params[:title],'description' => params[:description], 'tag' => params[:tag]})
    IdeaStore.save(idea)
    redirect '/'
  end

  put '/:id' do |id|
    idea = IdeaStore.find(id.to_i)
    idea.title = params[:title]
    idea.description = params[:description]
    idea.tag = params[:tag]
    IdeaStore.save(idea)
    redirect '/'
  end

  delete '/:id' do |id|
    IdeaStore.delete(id.to_i)
    redirect '/'
  end

  put '/:id/like' do |id|
    idea = IdeaStore.find(id.to_i)
    idea.like!
    IdeaStore.save(idea)
    redirect '/'
  end

  get '/:id' do |id|
    idea = IdeaStore.find(id.to_i)
    erb :edit, locals: {idea: idea}
  end

  get '/' do
    erb :index, locals: {ideas: IdeaStore.all.sort.reverse}
  end
end
