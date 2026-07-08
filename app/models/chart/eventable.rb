module Chart::Eventable
  extend ActiveSupport::Concern

  include ::Eventable

  included do
    # Replaces Eventable's polymorphic history: the chart is every event's
    # scope, so the name belongs to the whole stream (chart_id), which
    # includes the chart's own events.
    has_many :events, dependent: :destroy

    after_create :track_creation
    after_update :track_title_change, if: :saved_change_to_title?
    after_update :track_mode_change, if: :saved_change_to_mode?
  end

  private
    def track_creation
      track_event "created", chart: self
    end

    def track_title_change
      track_event "title_changed", chart: self, old_title: title_before_last_save, new_title: title
    end

    def track_mode_change
      track_event "mode_changed", chart: self, old_mode: mode_before_last_save, new_mode: mode
    end
end
