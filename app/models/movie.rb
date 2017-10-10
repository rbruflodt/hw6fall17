class Movie < ActiveRecord::Base
  def self.all_ratings
    %w(G PG PG-13 NC-17 R)
  end
  
class Movie::InvalidKeyError < StandardError ; end
  
  def self.find_in_tmdb(string)
    begin
      Tmdb::Api.key("f4702b08c0ac6ea5b51425788bb26562")
      dbMovies=Tmdb::Movie.find(string)
      movies = []
      if dbMovies
        dbMovies.each do |movie|
          rating = Movie.get_rating(movie.id)
          movies.append({:tmdb_id => movie.id, :title => movie.title, :rating => rating, :release_date => movie.release_date})
        end
      end
      return movies
    rescue Tmdb::InvalidApiKeyError
        raise Movie::InvalidKeyError, 'Invalid API key'
    end
  end
  
  def self.create_from_tmdb(id)
    movie_detail = Tmdb::Movie.detail(id)
    movie = {:title => movie_detail["title"], :rating => Movie.get_rating(id), :description => movie_detail["overview"], :release_date => movie_detail["release_date"]}
    Movie.create(movie)
  end
  
  def self.get_rating(id)
    rating = "unrated"
    Tmdb::Movie.releases(id)["countries"].each do |country|
      if country["iso_3166_1"] == "US"
        rating = country["certification"]
      end
    end
    return rating
  end

end
