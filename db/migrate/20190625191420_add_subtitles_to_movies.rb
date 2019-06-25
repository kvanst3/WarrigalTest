class AddSubtitlesToMovies < ActiveRecord::Migration[5.2]
  def change
    add_column :movies, :subtitle, :string
  end
end
