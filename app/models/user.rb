class User < ApplicationRecord
    has_many :attendances, dependent: :destroy # A student can have many attendance records
    validates :email, presence: true
end
