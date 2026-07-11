class Users::IncinerationJob < ApplicationJob
  # A user destroyed by another path before the wait elapses leaves this job
  # nothing to deserialize; it should shrug, not retry.
  discard_on ActiveJob::DeserializationError

  def self.schedule(user)
    set(wait: User::Closeable::INCINERATED_AFTER).perform_later(user)
  end

  def perform(user)
    User::Incineration.new(user).run
  end
end
