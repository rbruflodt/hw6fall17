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
end
