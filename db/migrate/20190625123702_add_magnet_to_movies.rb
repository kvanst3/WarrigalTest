class AddMagnetToMovies < ActiveRecord::Migration[5.2]
  def change
    add_column :movies, :magnet, :string
  end
end
