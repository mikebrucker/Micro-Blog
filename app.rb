require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/flash'
require 'bundler/setup'
require './models/user.rb'

enable :sessions

set :database, "sqlite3:micro_blogging_app.sqlite3"

get '/' do
    erb :index
end

get '/sign_out' do
    session[:user_id] = nil
    @user = nil
    erb :sign_out
end

get '/logged_in' do
    @user = current_user
    erb :logged_in
end

post '/sign-in' do
    user = User.where(username: params[:username]).first
    password = params[:password]
    if user && user.password == password
        session[:user_id] = user.id
        'good'
        redirect '/logged_in'
    else
        'bad'
    end
end

def current_user
    if session[:user_id]
        User.find(session[:user_id])
    end
end