require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/flash'
require 'bundler/setup'
require './models/user.rb'

enable :sessions

set :database, "sqlite3:micro_blogging_app.sqlite3"

get '/' do
    if session[:user_id]
        redirect '/blog'
    end
    erb :index
end

get '/blog' do
    if !session[:user_id]
        redirect '/'
    end
    erb :blog
end

get '/registration' do
    erb :registration
end

post '/register' do
    if params[:user][:password] == params[:confirm_password] && !User.where(username: [:user][:username]).first
        User.create[:user]
        user_id = User.where(username: [:username]).first.id
        Profile.create(fname: params[:fname], lname: params[:lname], email: params[:email], user_id: user_id)
    end
end

post '/sign-in' do
    user = User.where(username: params[:username]).first
    password = params[:password]
    if user && user.password == password
        session[:user_id] = user.id
        $user = current_user
        flash[:success] = 'Successfully Logged In'
    else
        flash[:error] = 'Log In Failed'
    end
    redirect '/'
end

post '/sign-out' do
    if current_user
        flash[:notice] = 'Signed Out'
    end
    sign_out
    redirect '/'
end

def current_user
    if session[:user_id]
        User.find(session[:user_id])
    end
end

def sign_out
    session[:user_id] = nil
    $user = nil
end