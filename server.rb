require 'sinatra'
require 'pg'

def db_connection
  begin
    connection = PG.connect(dbname:'movies')
    yield(connection)
  ensure
    connection.close
  end
end

get '/actors' do
  db_connection do |conn|
    @actors = conn.exec('SELECT name, id FROM actors ORDER BY name')
  end
  erb :actors
end


get '/actors/:id' do
  actor_id = params[:id]
  sql='SELECT actors.name AS actor, movies.title AS movie, movies.year AS year, genres.name AS genre FROM actors
      JOIN cast_members ON cast_members.actor_id=actors.id
      JOIN movies ON cast_members.movie_id = movies.id
      JOIN genres ON movies.genre_id = genres.id
      WHERE actors.id =$1'
    db_connection do |conn|
      @actors = conn.exec_params(sql,[actor_id])
    end
    @actors = @actors.to_a
  erb :actors_id
end


get '/movies' do
  db_connection do |conn|
    @movies = conn.exec('SELECT movies.title, movies.id, movies.year, movies.rating,
    genres.name AS genre, studios.name AS studio FROM movies
    JOIN genres ON movies.genre_id = genres.id
    JOIN studios ON studios.id= movies.studio_id')
  end
    @movies = @movies.to_a
  erb :movies
end

get '/movies/:id' do
  movie_id = params[:id]
  sql = 'SELECT movies.title AS movie,genres.name AS genre,movies.year AS year, actors.id AS actor_id, studios.name AS studio, actors.name AS actor, cast_members.character AS character FROM actors
  JOIN cast_members ON cast_members.actor_id = actors.id
  JOIN movies ON cast_members.movie_id = movies.id
  JOIN genres ON genres.id = movies.genre_id
  JOIN studios ON studios.id = movies.studio_id WHERE movies.id=$1'
  db_connection do |conn|
    @movies = conn.exec_params(sql,[movie_id])
  end
  @movies = @movies.to_a
  erb :movies_id
end










