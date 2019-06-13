require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
  @db = SQLite3::Database.new "MyBlog.db"
  @db.results_as_hash = true
end
before do

  init_db

end

configure do
  init_db
  @db.execute 'create table if not exists "Posts" (id integer primary key autoincrement,
                                      created_date date,
                                      content text
                                      personname text)'
  @db.execute 'create table if not exists "Comments" (id integer primary key autoincrement,
                                      created_date date,
                                      content text
                                      post_id integer
                                      personname text)'
end



get '/' do

  @results = @db.execute 'select * from Posts order by id desc'

  erb :index
end


get '/new' do
  erb :new
end

post '/new' do


personname = params[:personname]
content = params[:content]

if personname.strip.empty?
  @error = 'Type your name'
  return erb :new
end

if content.strip.empty?
  @error = 'Type post text'
  return erb :new
end

@db.execute 'insert into Posts (personname, content, created_date) values (?, ?, datetime())', [personname, content]

  redirect to '/'


end

get '/details/:post_id' do
  post_id = params[:post_id]



  results = @db.execute 'select * from Posts where id = ?', [post_id]
  @row = results[0]

  @comments = @db.execute 'select * from Comments where post_id = ? order by id', [post_id]

  erb :details

end


post '/details/:post_id' do

  post_id = params[:post_id]
  content = params[:content]
  if content.strip.empty?
    @error = 'Type comment'
    redirect to ('/details/' + post_id)
  end

  @db.execute 'insert into Comments (content, created_date, post_id) values (?, datetime(),?)', [content, post_id]


  redirect to ('/details/' + post_id)



end