class RenameMovieidToMovieId < ActiveRecord::Migration[5.2]
  def change
    rename_column :movies, :movieid, :movie_id
  end
end
