class User < ApplicationRecord
    has_many :attendances, dependent: :destroy  # A student can have many attendance records
    validates :email, presence: true, uniqueness: true  # Ensure email is present and unique
end
