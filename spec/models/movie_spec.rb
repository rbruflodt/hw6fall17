
describe Movie do
  describe 'searching Tmdb by keyword' do
    context 'with valid key' do
      it 'should call Tmdb with title keywords' do
        expect( Tmdb::Movie).to receive(:find).with('Inception')
        Movie.find_in_tmdb('Inception')
      end
      it 'should return a list of movies' do
        fake_results = [double({:id => 123, :title => "Movie 1", :release_date => "1995-18-9"}),double({:id => 456, :title => "Movie 2", :release_date => "1994-18-9"})]
        allow(Tmdb::Movie).to receive(:find).and_return(fake_results)
        expect(Tmdb::Movie).to receive(:releases).with(123).and_return({"countries" =>[{"iso_3166_1" => "US", "certification" => "R"},{"iso_3166_1" => "BR", "certification" => "G"}
        ]})
        expect(Tmdb::Movie).to receive(:releases).with(456).and_return({"countries" =>[{"iso_3166_1" => "US", "certification" => "G"},{"iso_3166_1" => "BR", "certification" => "PG"}
        ]})
        movies = Movie.find_in_tmdb('blah')
        expect(movies[0]).to include({:tmdb_id => 123, :title => "Movie 1", :release_date => "1995-18-9", :rating => "R"})
        expect(movies[1]).to include({:tmdb_id => 456, :title => "Movie 2", :release_date => "1994-18-9", :rating => "G"})
      end
    end
    context 'with invalid key' do
      it 'should raise InvalidKeyError if key is missing or invalid' do
        allow(Tmdb::Movie).to receive(:find).and_raise(Tmdb::InvalidApiKeyError)
        expect {Movie.find_in_tmdb('Inception') }.to raise_error(Movie::InvalidKeyError)
      end
    end
    it 'should add movies to the app' do
      expect(Tmdb::Movie).to receive(:detail).with(123).and_return({"title" => "Movie 1", "release_date" => "1995-18-9", "overview" => "overview"})
      expect(Movie).to receive(:get_rating).with(123).and_return("G")
      expect(Movie).to receive(:create).with({:title => "Movie 1", :release_date => "1995-18-9", :description => "overview", :rating => "G"})
      Movie.create_from_tmdb(123)
    end
  end
end
