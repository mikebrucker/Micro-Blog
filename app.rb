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
    am_i_logged_in
    erb :blog
end

get '/view_user' do 
    am_i_logged_in    
    erb :view_user
end

get '/edit_account' do
    am_i_logged_in    
    erb :edit_account
end

post '/edit-account' do 
    user = current_user
    if params[:account_password] == user.password
        user.profile.update_attributes(fname: params[:fname], lname: params[:lname], email: params[:email])
        flash[:success] = "Your Profile has been Updated"
        redirect '/profile'
    else
        flash[:notice] = "Incorrect Password"
    end
end

get '/edit_password' do
    am_i_logged_in    
    erb :edit_password
end

post '/edit-password' do
    user = current_user
    if params[:old_password] == "" || params[:new_password] == "" || params[:confirm_password] == ""
        flash[:error] = "Please Fill Out All Fields."
    end
    if params[:old_password] == user.password
        if params[:new_password] == params[:confirm_password]
            user.update_attributes(password: params[:new_password])
            flash[:success] = "Your password has been updated."
        end
        redirect '/'
    else
        flash[:notice] = "Passwords Do Not Match"
        redirect '/edit_password'
    end
end

get '/registration' do
    if session[:user_id]
        redirect '/blog'
    end
    erb :registration
end

post '/register' do
    if params[:user][:password] == params[:confirm_password]
        User.create(params[:user])
        user = User.where(username: params[:user][:username]).first
        Profile.create(fname: params[:profile][:fname], lname: params[:profile][:lname], email: params[:profile][:email], user_id: user.id)
    end
    redirect '/'
end

get '/create_post' do
    am_i_logged_in
    erb :create_post
end

get '/profile' do
    am_i_logged_in
    erb :profile
end

get '/delete_account' do
    am_i_logged_in
    erb :delete_account
end

post '/create-post' do
    if params[:post][:title].length > 0 && params[:post][:body].length > 0
        user = current_user
        Post.create(title: params[:post][:title], body: params[:post][:body], user_id: user.id)
        redirect '/blog'
    end
end

post '/register' do
    if User.where(username: params[:user][:username]).first
        flash[:notice] = 'Username Already Taken'
        redirect '/registration'
        return
    elsif params[:user][:password] == params[:confirm_password] && !User.where(username: params[:user][:username]).first
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

def am_i_logged_in
    if !session[:user_id]
        redirect '/'
    end    
end