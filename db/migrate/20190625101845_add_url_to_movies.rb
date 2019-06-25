class AddUrlToMovies < ActiveRecord::Migration[5.2]
  def change
    add_column :movies, :url, :string
  end
end
