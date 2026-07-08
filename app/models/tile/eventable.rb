module Tile::Eventable
  extend ActiveSupport::Concern

  include ::Eventable

  included do
    before_save :remember_body_change
    after_update :track_title_change, if: :saved_change_to_title?
    after_update :track_subtitle_change, if: :saved_change_to_subtitle?
    after_update :track_body_change, if: :body_changed?
    after_update :track_summarization, if: :saved_change_to_agentic_summary?
  end

  private
    # Rich text lives in its own autosaved record, so saved_change_to_body?
    # doesn't exist; note the dirty association before the change set clears.
    def remember_body_change
      @body_changed = association(:rich_text_body).target&.changed? || false
    end

    def body_changed?
      @body_changed
    end

    def track_title_change
      track_event "title_changed", old_title: title_before_last_save, new_title: title
    end

    def track_subtitle_change
      track_event "subtitle_changed", old_subtitle: subtitle_before_last_save, new_subtitle: subtitle
    end

    def track_body_change
      track_event "body_changed"
    end

    def track_summarization
      track_event "summarized"
    end
end
