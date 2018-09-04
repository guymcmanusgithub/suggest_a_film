require  'csv'

# loading all the required files from csv files
movie_names = CSV.read("/Users/athoi/apps/ruby/excercises/suggest_a_film/movies.csv")
all_user_rating = CSV.read("/Users/athoi/apps/ruby/excercises/suggest_a_film/ratings.csv")


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
p movie_data