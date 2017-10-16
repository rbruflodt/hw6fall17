require 'spec_helper'
require 'rails_helper'

describe MoviesController do
  describe 'searching TMDb' do
   it 'should call the model method that performs TMDb search' do
      fake_results = [double('movie1'), double('movie2')]
      expect(Movie).to receive(:find_in_tmdb).with('Ted').
        and_return(fake_results)
      post :search_tmdb, {:search_terms => 'Ted'}
    end
    it 'should select the Search Results template for rendering' do
      fake_results = [double('Movie'), double('Movie')]
      allow(Movie).to receive(:find_in_tmdb).and_return (fake_results)
      post :search_tmdb, {:search_terms => 'Ted'}
      expect(response).to render_template('search_tmdb')
    end  
    it 'should make the TMDb search results available to that template' do
      fake_results = [double('Movie'), double('Movie')]
      allow(Movie).to receive(:find_in_tmdb).and_return (fake_results)
      post :search_tmdb, {:search_terms => 'Ted'}
      expect(assigns(:movies)).to eq(fake_results)
    end 
    it 'should redirect to the home page when the search is invalid' do
      fake_results = [double('Movie'), double('Movie')]
      allow(Movie).to receive(:find_in_tmdb).and_return (fake_results)
      post :search_tmdb, {:search_terms => ""}
      expect(response).to redirect_to("/movies")
    end 
    it 'should redirect to the home page when there are no matching movies' do
      fake_results = nil
      allow(Movie).to receive(:find_in_tmdb).and_return (fake_results)
      post :search_tmdb, {:search_terms => "Ted"}
      expect(response).to redirect_to("/movies")
    end
    it 'should add selected movies to the app' do
      expect(Movie).to receive(:create_from_tmdb).with(123).and_return(nil)
      expect(Movie).to receive(:create_from_tmdb).with(456).and_return(nil)
      post :add_tmdb, {:tmdb_movies => {123 => 1,456 => 1}}
      expect(response).to redirect_to("/movies")
    end
    it 'should flash a message if no movies are selected to add' do
      post :add_tmdb, {:tmdb_movies => nil}
      expect(flash[:notice]).to eq("No movies selected")
      expect(response).to redirect_to("/movies")
    end
  end
  describe 'using the routes' do
    it 'should add movies to the database' do
      new_movie = {:movie=>{:title => 'Movie', :rating => 'G', :description => 'Description', :release_date => '2017-1-1'}}
      expect(Movie).to receive(:create!).with(new_movie[:movie]).and_return(double(new_movie[:movie]))
      post :create, new_movie
      expect(flash[:notice]).to eq("Movie was successfully created.")
      expect(response).to redirect_to("/movies")
    end
    it 'should update movies' do
      movie_params = {:id=>1,:movie=>{:title => 'Movie', :rating => 'G', :description => 'Description', :release_date => '2017-1-1'}}
      movie = double(movie_params[:movie])
      expect(Movie).to receive(:find).with("1").and_return(movie)
      post :edit, movie_params
      expect(assigns(:movie)).to eq(movie)
      expect(Movie).to receive(:find).with("1").and_return(movie)
      expect(movie).to receive(:update_attributes!).with(movie_params[:movie]).and_return(nil)
      put :update, movie_params
      expect(flash[:notice]).to eq("Movie was successfully updated.")
    end 
    it 'should destroy movies' do
      movie_params = {:id=>1,:movie=>{:title => 'Movie', :rating => 'G', :description => 'Description', :release_date => '2017-1-1'}}
      movie = double(movie_params[:movie])
      expect(Movie).to receive(:find).with("1").and_return(movie)
      expect(movie).to receive(:destroy)
      delete :destroy, movie_params
      expect(flash[:notice]).to eq("Movie 'Movie' deleted.")
      expect(response).to redirect_to("/movies")
    end
    it 'should show movie details' do
      movie_params = {:id=>1,:movie=>{:title => 'Movie', :rating => 'G', :description => 'Description', :release_date => '2017-1-1'}}
      movie = double(movie_params[:movie])
      expect(Movie).to receive(:find).with("1").and_return(movie)
      get :show, movie_params
      expect(assigns(:movie)).to eq(movie)
    end
  end
end
