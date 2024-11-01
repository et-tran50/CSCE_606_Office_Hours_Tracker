class TaAttendance < ApplicationRecord
  belongs_to :user

  # Set default values for attributes after initialization
  after_initialize :set_defaults

  private

  # Sets checked_in_names to an empty array if it's nil
  def set_defaults
    self.checked_in_names ||= []
  end
end
