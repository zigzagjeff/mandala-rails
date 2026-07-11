class User::Export
  def initialize(user)
    @user = user
  end

  def export_json
    JSON.pretty_generate document.as_json
  end

  private
    def document
      { account: account, charts: charts }
    end

    def account
      {
        email_address: @user.email_address,
        created_at: @user.created_at,
        verified_at: @user.verified_at
      }
    end

    def charts
      @user.charts.map { |chart| chart_document chart }
    end

    def chart_document(chart)
      {
        title: chart.title,
        mode: chart.mode,
        created_at: chart.created_at,
        grid: grid_document(chart.root_grid),
        events: chart.events.chronologically.map { |event| event_document event }
      }
    end

    def grid_document(grid)
      { tiles: grid.tiles.positioned.map { |tile| tile_document tile } }
    end

    def tile_document(tile)
      {
        position: tile.position,
        title: tile.title,
        subtitle: tile.subtitle,
        body: tile.body.to_s,
        agentic_summary: tile.agentic_summary,
        child_grid: tile.child_grid && grid_document(tile.child_grid)
      }
    end

    def event_document(event)
      {
        action: event.action,
        created_at: event.created_at,
        particulars: event.particulars
      }
    end
end
