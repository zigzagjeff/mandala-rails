module User::Closeable
  extend ActiveSupport::Concern

  # Shared between the job that schedules the wait and the views that show the
  # deletion date, so it lives on the concern rather than the job (canon C6.5).
  INCINERATED_AFTER = 14.days

  def close
    unless closed?
      update! closed_at: Time.current
      Users::IncinerationJob.schedule self
    end
  end

  def reopen
    if closed?
      update! closed_at: nil
    end
  end

  def closed?
    closed_at.present?
  end

  def deletes_on
    closed_at + INCINERATED_AFTER if closed?
  end
end
