require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'

get '/:title' do
  @title = params[:title]
  erb :home
end
