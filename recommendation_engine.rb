##########  LOADING ALL THE GEMS #########
require 'csv'
require 'pearson'
require 'tty-spinner'
require 'colorize'
spinner = TTY::Spinner.new("[:spinner] Loading your recommendations...", format: :pulse_2)
# spinner = TTY::Spinner.new("wait :spinner ...", format: :spin_2)

##########  LOADING THE CSV FILES FROM MOVIELENS #########
movie_names = CSV.read("./movies.csv")
all_user_rating = CSV.read("./ratings.csv")

#The number of individual users within the dataset.  Will be used to iterate over the data.
number_of_users_in_db = 671

## remove the field names/headers from the first entry within the csv
movie_names.shift
all_user_rating.shift

## Remove the timestamp from each row using pop as it is the last element
user_data = []    
all_user_rating.each do |rows|
  rows.pop
  user_data << rows
end
# user data is now the user ratings without the timestamp

movie_data = []   # movie data is the movie list without the genres
movie_names.each do |rows|
  rows.pop
  movie_data << rows
end

# p movie_data.length #Used for testing
# p user_data.length #Used for testing

######### GETTING TOP 100 MOST RATED MOVIES FOR USER TO RATE FROM ##########

# find out the movies that have been rated most often
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

# p sorted_movies #Used for testing
# p most_rated_movies #Used for testing

# FOR TESTING!!! (Gretch made us do this)
# sorted_most_rated_movies.each do |k, v|
#   hashmovies = "movieID #{k} was rated #{v} times \n"
#   # print hashmovies
# end

# saving the hundred most rated movies
top_hundred_movies = sorted_most_rated_movies[1..100]

# match movie ids in movie_data with movie ids in top_hundred_movies variable 
# and enter the title inside the top_100 array 
movie_data.each do |item|
  top_hundred_movies.each do |movie|
    if item[0] == movie[0]
      movie << item[1]
    end 
  end  
end 

# p top_hundred_movies #Used for testing

######### USER INTERFACE ########

# Generate randomly selected movies for the user to rate from the top_hundred_movies variable
movies_and_ratings = []
print "How many movies would you like to review? \n(keep in mind that the more movies you review the more accurate our recommendations will be): "
number_of_movies_to_rate = gets.chomp.to_i
puts "Please rate the #{number_of_movies_to_rate} movies below:"

counter = 0
while counter < number_of_movies_to_rate
  current_movie_to_rate = top_hundred_movies[rand(100)] # this generates random movies from the top_hundred_movies array
  current_movie_title = current_movie_to_rate[2] #Saves the movie title in the current_movie_title variable 
  current_movie_id = current_movie_to_rate[0] #Saves the movie id in the variable current_movie_id
  print "Please rate #{current_movie_title.blue} from 1 to 5: "
  #Following lines of code get user responses and store them in a hash, while assigning the user with the userID '5000'
  current_user_rating = gets.chomp.to_f
  rating_hash = {
    user_id: "5000",
    movie_id: current_movie_id,
    movie_title: current_movie_title,
    user_rating: current_user_rating
  }
  movies_and_ratings << rating_hash #This pushes the users ratings into the movies_and_ratings array
  counter += 1
end
# print movies_and_ratings # Used for testing

#### LOADING TTY:Spinner icon while the program calculates the recommendations
spinner.auto_spin 

####### CREATING A HASH FROM USER INPUTS TO USE WITH THE PEARSON GEM #######
movies_ids = []
movies_ratings = []
movies_and_ratings.each do |hash|
  movies_ids << hash[:movie_id]
  movies_ratings << hash[:user_rating]
end
user_5000_hash = movies_ids.zip(movies_ratings).to_h 
#The .zip method combines the two arrays (of same length). Then we convert into one hash
user_5000_hash_for_pearsons = {rating_hash[:user_id] => user_5000_hash}

# p user_5000_hash_for_pearsons #Used for testing
# print movies_ids #Used for testing
# print movies_ratings #Used for testing
# print user_data #Used for testing

######### CREATING A HASH FROM MOVIELENS DATA TO MATCH THE STRUCTURE REQUIRED BY THE PEARSON GEM ######
def create_hash_of_movieid_and_ratings_for_each_user(user_data_array,userid)
  all_movies_rated_by_each_user = []
  all_ratings_by_each_user = []
  user_data_array.each do |item|
    if item[0] == userid
      # print item,index #Used for testing
      all_movies_rated_by_each_user << item[1] # pushes movieId into an array 
      all_ratings_by_each_user << item[2].to_f # changes the ratings to floats to use the pearson gem
    end
  end
  user_hash = all_movies_rated_by_each_user.zip(all_ratings_by_each_user).to_h
  user_hash #returns the newly merged hash of the hashes listed above
end

counter = 1
array_of_user_hashes = [] ## used the method create_hash_of_movieid_and_ratings_for_each_user in a loop to create hashes for all the users in the ratings.csv file
while counter <= number_of_users_in_db 
  user = create_hash_of_movieid_and_ratings_for_each_user(user_data, "#{counter}")
  array_of_user_hashes << user
  counter += 1
end
counter = 1
array_of_id_of_user = []
while counter <= number_of_users_in_db
  array_of_id_of_user << "#{counter}"
  counter += 1
end
# p array_of_user_hashes # Used for testing
# p array_of_id_of_user # Used for testing
scores_users = array_of_id_of_user.zip(array_of_user_hashes).to_h
# p scores_users # Used for testing

########## ADDING USER INPUT HASH TO THE HASH OF ALL THE OTHER USERS #########
combined_hash = scores_users.merge(user_5000_hash_for_pearsons)
# p combined_hash # Used for testing
# p Pearson.coefficient(combined_hash, '5000', '4') # Used for testing
# p Pearson.closest_entities(combined_hash, '5000', limit: 5) # Used for testing

########### CREATING MOVIE RECOMMENDATIONS FOR USER ###########
recommended_movies = Pearson.recommendations(combined_hash, '5000') # '5000' is the assigned userId to the user
recommended_list = []
recommended_movies.each do |movie_id|
  movie_data.each do |movie|
    if movie_id[0] == movie[0]
      recommended_list << movie[1].green
    end
  end
end

spinner.stop("\nWe recommend these movies to you: \n")
puts recommended_list

