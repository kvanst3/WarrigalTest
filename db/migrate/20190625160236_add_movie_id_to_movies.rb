class AddMovieIdToMovies < ActiveRecord::Migration[5.2]
  def change
    add_column :movies, :movieid, :string
  end
end
