class Event < ApplicationRecord
  belongs_to :mandala
  belongs_to :creator, class_name: "User"
  belongs_to :eventable, polymorphic: true

  scope :chronologically, -> { order created_at: :asc, id: :asc }
  scope :since, ->(time) { where("created_at > ?", time) if time }

  after_create_commit -> { broadcast_refresh_later_to mandala }

  thread_mattr_accessor :recording, default: true

  def self.suppressing_recording(&block)
    original, self.recording = self.recording, false
    yield
  ensure
    self.recording = original
  end
end
