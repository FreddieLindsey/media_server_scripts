import os
from sys import argv
from tmdbsimple import TMDB

script, movie_name, requested_data = argv

# Set up variables for searching
tmdb = TMDB('65e72e1a838dca2bea6c0bb279566446')
search = tmdb.Search()

# Search by Movie Name
response = search.movie({'query': "'"+movie_name+"'"})
main_movie = search.results[0]
print(main_movie[requested_data])