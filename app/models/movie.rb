class Movie < ApplicationRecord
  belongs_to :user
  has_many :serie, dependent: :destroy
end
