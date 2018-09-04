require  'csv'

movie_names = CSV.read("/Users/athoi/apps/ruby/excercises/suggest_a_film/movies.csv")
all_user_rating = CSV.read("/Users/athoi/apps/ruby/excercises/suggest_a_film/ratings.csv")
p all_user_rating