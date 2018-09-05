require  'csv'
require 'pearson'

# loading all the required files from csv files
movie_names = CSV.read("/Users/athoi/apps/ruby/excercises/suggest_a_film/movies.csv")
all_user_rating = CSV.read("/Users/athoi/apps/ruby/excercises/suggest_a_film/ratings.csv")
number_of_users_in_db = 671
## remove the fields
movie_names.shift
all_user_rating.shift

## Remove the timestamp from each row using pop as it is the last element
user_data = []    # user data is the user ratings without the timestamp
all_user_rating.each do |rows|
  rows.pop
  user_data << rows
end

movie_data = []   # movie data is the movie list without the genres
movie_names.each do |rows|
  rows.pop
  movie_data << rows
end


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

## Generate randomly selected 5 or 10 movies for the user to rate
movies_and_ratings = []
puts "please rate the five movies below:"
counter = 0
while counter < 10
  current_movie_to_rate = top_hundred_movies[rand(100)] # this generates random movies from the to_100 array
  current_movie_title = current_movie_to_rate[2]
  current_movie_id = current_movie_to_rate[0]
  print "please rate #{current_movie_title} from 1 to 5: "
  current_user_rating = gets.chomp.to_f
  rating_hash = {
    user_id: "5000",
    movie_id: current_movie_id,
    movie_title: current_movie_title,
    user_rating: current_user_rating
  }
  movies_and_ratings << rating_hash
  counter += 1
end
puts
# print movies_and_ratings
puts
movies_ids = []
movies_ratings = []
movies_and_ratings.each do |hash|
  movies_ids << hash[:movie_id]
  movies_ratings << hash[:user_rating]
end
user_5000_hash = movies_ids.zip(movies_ratings).to_h
user_5000_hash_for_pearsons = {rating_hash[:user_id] => user_5000_hash}
# p user_5000_hash_for_pearsons
# print movies_ids
# puts
# print movies_ratings


# print user_data
def create_hash_of_movieid_and_ratings_for_each_user(user_data_array,userid)
  all_movies_rated_by_each_user = []
  all_ratings_by_each_user = []
  user_data_array.each do |item|
    if item[0] == userid
      # print item,index
      all_movies_rated_by_each_user << item[1]
      all_ratings_by_each_user << item[2].to_f # changed the ratings to floats to use the pearson gem
    end
  end
  user_hash = all_movies_rated_by_each_user.zip(all_ratings_by_each_user).to_h
  user_hash
end

### PROBLEMS : found out that in ruby you cannot use a variable in a mthod 
### that is outside of the method without passing it in the argument
### in this case it is the variable "user_data"
counter = 1
array_of_each_user = [] ## used the method in a loop to create hashes for all the users in the ratings.csv file
while counter <= number_of_users_in_db # usernumber in the dataset is 671
  user = create_hash_of_movieid_and_ratings_for_each_user(user_data, "#{counter}")
  array_of_each_user << user
  counter += 1
end
counter = 1
array_of_id_of_user = []
while counter <= number_of_users_in_db
  array_of_id_of_user << "#{counter}"
  counter += 1
end
##
# p array_of_each_user
# p array_of_id_of_user
scores_users = array_of_id_of_user.zip(array_of_each_user).to_h
combined_hash = scores_users.merge(user_5000_hash_for_pearsons)
# p combined_hash

# # p scores_users

# p Pearson.coefficient(combined_hash, '5000', '4')
# puts
# p Pearson.closest_entities(combined_hash, '5000', limit: 5) 

p Pearson.recommendations(combined_hash, '5000')