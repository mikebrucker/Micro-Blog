require 'bundler/setup'
require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/flash'
require './models/user.rb'
require './models/profile.rb'
require './models/post.rb'

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

get '/view_user' do 
    if !session[:user_id]
        redirect '/'
    end
    
    erb :view_user
end


get '/registration' do
    if session[:user_id]
        redirect '/blog'
    end
    erb :registration
end

get '/create_post' do
    if !session[:user_id]
        redirect '/'
    end
    erb :create_post
end

post '/create-post' do
    if params[:post][:title].length > 0 && params[:post][:body].length > 0
        user = current_user
        Post.create(title: params[:post][:title], body: params[:post][:body], user_id: user.id)
        redirect '/blog'
    end
end


post '/register' do
    if params[:user][:password] == params[:confirm_password]
        User.create(params[:user])
        user = User.where(username: params[:user][:username]).first
        Profile.create(fname: params[:profile][:fname], lname: params[:profile][:lname], email: params[:profile][:email], user_id: user.id)
    end
    redirect '/'
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
