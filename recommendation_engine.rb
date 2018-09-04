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
sorted_most_rated_movies = most_rated_movies.sort_by{|k, v| v}.reverse

# print sorted_movies
# p most_rated_movies

sorted_most_rated_movies.each do |k, v|
  hashmovies = "movieID #{k} was rated #{v} times \n"
  # print hashmovies
end

## the top hundred movies
top_hundred_movies = sorted_most_rated_movies[1..100]

# match movie ids in movie_data with movie ids in top_100list
# enter the title inside the top_100 array 

movie_data.each do |item|
  top_hundred_movies.each do |movie|
    if item[0] == movie[0]
      movie << item[1]
    end 
  end  
end 

# p top_hundred_movies

### Generate randomly selected 5 or 10 movies for the user to rate
movies_and_ratings = []
puts "please rate the five movies below:"
counter = 0
while counter < 5
  current_movie_to_rate = top_hundred_movies[rand(100)] # this generates random movies from the to_100 array
  current_movie_title = current_movie_to_rate[2]
  current_movie_id = current_movie_to_rate[0]
  print "please rate #{current_movie_title} from 1 to 5: "
  user_rating = gets.chomp.to_f
  rating_hash = {
    userid: "5000",
    movie_id: current_movie_id,
    movie_title: current_movie_title,
    user_rating: user_rating
  }
  movies_and_ratings << rating_hash
  # user_votes << vote_title
  counter += 1
end

print movies_and_ratings
puts
movies_ids = []
movies_and_ratings.each do |hash|
  movie_ids << hash[:movie_id]
end




