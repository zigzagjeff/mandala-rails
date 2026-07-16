module Mandala::Eventable
  extend ActiveSupport::Concern

  include ::Eventable

  included do
    # Replaces Eventable's polymorphic history: the mandala is every event's
    # scope, so the name belongs to the whole stream (mandala_id), which
    # includes the mandala's own events.
    has_many :events, dependent: :destroy

    after_create :track_creation
    after_update :track_title_change, if: :saved_change_to_title?
  end

  private
    def track_creation
      track_event "created", mandala: self
    end

    def track_title_change
      track_event "title_changed", mandala: self, old_title: title_before_last_save, new_title: title
    end
end
