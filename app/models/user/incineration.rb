class User::Incineration
  def initialize(user)
    @user = user
  end

  def run
    @user.destroy if possible?
  end

  # Re-verified at execution time, not just at scheduling: a far-future job
  # outlives its premises (canon C6.2). An account closed, reopened, then
  # closed again leaves the first job's wait stale — `due?` rejects it so the
  # second grace period is honored rather than cut short.
  def possible?
    closed? && due?
  end

  private
    def closed?
      @user.closed?
    end

    def due?
      @user.closed_at <= User::Closeable::INCINERATED_AFTER.ago
    end
end
