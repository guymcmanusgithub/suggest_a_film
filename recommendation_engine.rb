require  'csv'

# loading all the required files from csv files
movie_names = CSV.read("/Users/athoi/apps/ruby/excercises/suggest_a_film/movies.csv")
all_user_rating = CSV.read("/Users/athoi/apps/ruby/excercises/suggest_a_film/ratings.csv")

## remove the fields
movie_names.shift
all_user_rating.shift

## Remove the timestamp from each row using pop as it is the last element
user_data = []
all_user_rating.each do |rows|
  rows.pop
  user_data << rows
end
# user data is the user ratings without the timestamp

movie_data = []
movie_names.each do |rows|
  rows.pop
  movie_data << rows
end

# movie data is the movie list without the genres
# p movie_data.length
# p user_data.length

# find out the movies that have been rated the most often
movies_rated_often = []
user_data.each do |ratings|
  movies_rated_often << ratings[1]
end
# p movies_rated_often.sort

most_rated_movies = Hash.new(0)

movies_rated_often.each do |movie|
  most_rated_movies[movie] += 1
end

most_rated_movies.each do |k, v|
  hashmovies = "movieID #{k} was rated #{v} times \n"
  print hashmovies
end

