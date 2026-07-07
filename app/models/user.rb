class User < ApplicationRecord
  has_secure_password
  has_secure_token :api_token
  has_many :sessions, dependent: :destroy
  has_many :charts, dependent: :destroy
  has_many :grids, through: :charts
  has_many :tiles, through: :grids

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
