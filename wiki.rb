require 'sinatra'
require 'data_mapper'
DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/wiki.db")
class User
  include DataMapper::Resource
  property :id, Serial
  property :username, Text, :required => true
  property :password, Text, :required => true
  property :date_joined, DateTime
  property :edit, Boolean, :required => true, :default => false
end

DataMapper.finalize.auto_upgrade!

$myinfo = ""
@info = ""

def readFile(filename)
  info = ""
  file = File.open(filename)
  file.each do |line|
    info = info + line
  end
  file.close
  $myinfo = info
end

helpers do
  def adminprotected!
    if authorizedadmin?
      return
    end
    redirect '/admindenied'
  end
  def authorizedadmin?
    if $credentials != nil
      @Userz = User.first(:username => $credentials[0])
      if @Userz
        if @Userz.edit == true
          return true
        else
          return false
        end
      else
        return false
      end
    end
  end
end

helpers do
  def protected!
    if authorized?
      return
    end
    redirect '/denied'
  end
  def authorized?
    if $credentials != nil
      @Userz = User.first(:username => $credentials[0])
      if @Userz
        return true
      else
        return false
      end
    else
      return false
    end
  end
end


get '/' do
  info = ""
  len = info.length
  len1 = len
  readFile("wiki.txt")
  @info = info + " " + $myinfo
  len = @info.length
  len2 = len - 1
  len3 = len2 - len1
  @words = len3.to_s

  erb :home
end

get '/about' do

  erb :about
end

get '/create' do

  erb :create
end

get '/edit' do
  adminprotected!
  info = ""
  file = File.open("wiki.txt")
  file.each do |line|
    info = info + line
  end
  file.close
  @info = info
  erb :edit
end

put '/edit' do
  info = "#{params[:message]}"
  @info = info
  file = File.open("wiki.txt", "w")
  file.puts @info
  file.close
  redirect '/edit'
end

get '/login' do
  erb :login
end

post '/login' do
  $credentials = [params[:username],params[:password]]
  @users = User.first(:username => $credentials[0])
  if @users
    if @users.password == $credentials[1]
      redirect '/'
    else
      $credentials = ['','']
      redirect '/wrongaccount'
    end
  else
    $credentials = ['','']
    redirect '/wrongaccount'
  end
end

get '/createaccount' do
  erb :createaccount
end

post '/createaccount' do
  n = User.new
  n.username = params[:username]
  n.password = params[:password]
  n.date_joined = Time.now
  if n.username == "Admin" and n.password == "Password"
    n.edit = true
  end
  n.save
  redirect '/login'
end

get '/usernametaken' do
  erb :usernametaken
end

get '/admincontrols' do
  adminprotected!
  @list2 = User.all :order => :id.desc
  erb :admincontrols
end

get '/wrongaccount' do
  erb :wrongaccount
end

get '/user/:uzer' do
  @userz = User.first(:username => params[:uzer])
  if @userz != nil
    erb :profile
  else
    redirect '/noaccount'
  end
end

put '/user/:uzer' do
  n = User.first(:username => params[:uzer])
  n.edit = params[:edit] ? 1 : 0
  n.save
  redirect '/'
end

get '/user/delete/:uzer' do
  adminprotected!
  n = User.first(:username => params[:uzer])
  if n.username == "Admin"
    erb :admindenied
  else
    n.destroy
    @list2 = User.all :order => :id.desc
    erb :admincontrols
  end
end

get '/logout' do
  $credentials = ['','']
  redirect '/'
end

get '/notfound' do
  erb :notfound
end

get '/noaccount' do
  erb :noaccount
end

get '/admindenied' do
  erb :admindenied
end

get '/denied' do
  erb :denied
end

not_found do
  status 404
  redirect '/notfound'
end