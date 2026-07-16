module Eventable
  extend ActiveSupport::Concern

  included do
    has_many :events, as: :eventable, dependent: :destroy
  end

  def track_event(action, creator: Current.user, mandala: self.mandala, **particulars)
    if should_track_event?
      mandala.events.create!(action: "#{eventable_prefix}_#{action}", creator:, eventable: self, particulars:)
    end
  end

  private
    def should_track_event?
      Event.recording && Current.user.present?
    end

    def eventable_prefix
      self.class.name.demodulize.underscore
    end
end
