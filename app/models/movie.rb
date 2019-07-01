class Movie < ApplicationRecord
  belongs_to :user
  has_many :serie, dependent: :destroy

  def is_movie?
    movietype == "movie"
  end

  def is_series?
    movietype == "series"
  end
end
