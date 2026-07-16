# The onboarding mandala every new user starts with, so the blank slate teaches
# instead of intimidating (issue #136). The content is a versioned snapshot of the
# hand-authored "Start Here" mandala — baked in here rather than read live from a
# designated source record, because a template must not depend on a mutable
# production row.
#
# The center tile (position 4) is titled "Start Here" for free by
# Mandala#seed_root_grid, which titles the center from the mandala title; this
# class fills only the four surrounding tiles that carry the help copy.
class Mandala::StartHereTemplate
  TITLE = "Start Here"

  SURROUNDING_TILES = {
    0 => {
      title: "What is a Mandala?",
      body: %q(<p>The Mandala Chart is a structured visual tool for goal setting and personal development, originating from <a href="https://grokipedia.com/page/Japanese_management_culture">Japanese productivity techniques</a> as part of the Harada Method, featuring a 9x9 grid layout with a central long-term ambition supported by eight key pillars and 64 detailed actionable steps.<a href="https://grokipedia.com/page/Mandala_Chart#ref-1"></a><a href="https://grokipedia.com/page/Mandala_Chart#ref-1"><sup>[1]</sup></a><a href="https://grokipedia.com/page/Mandala_Chart#ref-2"></a><a href="https://grokipedia.com/page/Mandala_Chart#ref-2"><sup>[2]</sup></a> Developed by Japanese educator Takashi Harada in the <a href="https://grokipedia.com/page/1980s_in_Japan">1980s</a> to foster <a href="https://grokipedia.com/page/Self-Reliance">self-reliance</a> and continuous improvement, the chart encourages users to break down ambitious objectives into specific, measurable daily actions, emphasizing mindset shifts and <a href="https://grokipedia.com/page/Behavioural_change_theories">behavioral changes</a> over mere task lists.<a href="https://grokipedia.com/page/Mandala_Chart#ref-2"></a><a href="https://grokipedia.com/page/Mandala_Chart#ref-2"><sup>[2]</sup></a> It gained widespread international attention in the <a href="https://grokipedia.com/page/2010s">2010s</a> through its adoption by <a href="https://grokipedia.com/page/Major_League_Baseball">MLB</a> superstar Shohei Ohtani, who as a high school freshman around 2010 created a detailed Mandala Chart mapping his dream of becoming a major league player, including goals like daily batting practice, <a href="https://grokipedia.com/page/English_as_a_second_or_foreign_language">English study</a>, and <a href="https://grokipedia.com/page/Athletic_training">physical conditioning</a>, which he credits for his success.<a href="https://grokipedia.com/page/Mandala_Chart#ref-1"></a><a href="https://grokipedia.com/page/Mandala_Chart#ref-1"><sup>[1]</sup></a><a href="https://grokipedia.com/page/Mandala_Chart#ref-3"></a><a href="https://grokipedia.com/page/Mandala_Chart#ref-3"><sup>[3]</sup></a></p><p>Seeded from <a href="https://grokipedia.com/page/Mandala_Chart#ref-1">Grokipedia</a></p>)
    },
    1 => {
      title: "How to Use It",
      body: %q(<p>Each Mandala has a front page made up of a center tile for theme, and surrounding tiles for topics</p><p>Clicking the top of a tile will allow you to create a title for the topic. </p><p>Once you have created a topic, clicking that tile will open up a fully featured markdown text editor to say more about the topic. </p><p>Clicking ▶️ in the lower right hand corner of each tile will load a child mandala. The parent topic tile now loads into the center, and the surrounding tiles allow you to create sub topics. Clicking the sub-topic tile again opens up a text editor. </p>)
    },
    2 => {
      title: "How you can help",
      body: %q(<p>I created demo Mandalas for each user. There is no privacy. Everyone can see everyone's Mandala. </p><p>Poke around. Name tiles. </p><h2>Ideally, answer this question: </h2><blockquote><p>What's on my mind. </p></blockquote><p>Let me know if you encounter specific broken behaviors? </p><p>What did you expect to happen that didn't happen? </p><p>What do you wish it could do? </p><p>The big one is navigation. </p>)
    },
    3 => {
      title: "What's next?",
      body: %q(<h3>Individual user accounts</h3><ul><li value="1">Create accounts.<ul><li value="1">All data conforming to EU data standards</li><li value="2">This app exists on a Hetzner server in Nuremberg</li><li value="3">All backups are on Scaleway in Paris</li></ul></li><li value="2">Login</li><li value="3">Just like any SaaS</li></ul><h3>Sidebar widgets</h3><ul><li value="1">A task editor on the left or right</li><li value="2">An AI chat on the left or right</li></ul><h3>AI</h3><ul><li value="1">This was written as an AI-first app.<ul><li value="1">The SQLite database for each mandala has an ID for each individual tile.</li><li value="2">The schema for each tile includes user facing data such as title, subtitle, and body</li><li value="3">The schema also includes an AI summary.</li><li value="4">The goal is for a background agent to interact with the user data and create a token efficient summary. </li><li value="5">Mistral will be used as the model, making this a 100% EU app. </li></ul></li><li value="2">This will allow the app to selectively load whatever depth of summaries into the context and the user to chat with the mandala.<ul><li value="1">Chat with a single page</li><li value="2">Chat with a specific grid.</li><li value="3">Chat with the entire chart.</li></ul></li></ul>)
    }
  }.freeze

  def self.seed_for(user)
    new(user).seed
  end

  def initialize(user)
    @user = user
  end

  # Seeding is silent by design, not by circumstance: suppression wraps the
  # mandala's own creation too, so no event records even when a Current.user is
  # set (a console or admin path), where otherwise the seed would attribute a
  # mandala_created event to whoever happened to be acting.
  def seed
    Event.suppressing_recording do
      @user.mandalas.create!(title: TITLE).tap do |mandala|
        fill_surrounding_tiles mandala.root_grid
      end
    end
  end

  private
    def fill_surrounding_tiles(grid)
      SURROUNDING_TILES.each do |position, content|
        grid.tiles.find_by!(position:).update!(content)
      end
    end
end
