class AddMovieRefToSerie < ActiveRecord::Migration[5.2]
  def change
    add_reference :series, :movie, foreign_key: true
  end
end
