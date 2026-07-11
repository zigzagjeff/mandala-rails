class Closures::ScheduledJob < ApplicationJob
  def perform(user)
    ClosureMailer.scheduled(user).deliver_now
  end
end
