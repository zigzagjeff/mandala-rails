# Third-party notices

Mandala was developed with 37signals' Fizzy
(https://github.com/basecamp/fizzy) as a reference for Rails structure and
conventions. Most of Mandala is original work; the following portion is a
direct adaptation of Fizzy source, included here per condition 1 of
Fizzy's O'Saasy License:

- `app/models/concerns/eventable.rb` — adapted from Fizzy's
  `app/models/concerns/eventable.rb`. The polymorphic `events` association,
  the `track_event` shape, and `eventable_prefix` are Fizzy's; the domain is
  renamed from board to mandala, and the recording guard
  (`should_track_event?`) is Mandala's own.

Fizzy's design conventions also informed several other files
(authentication, session, and export patterns), but those were rebuilt for
Mandala's domain rather than copied.

Mandala's own `LICENSE` is the O'Saasy License, the same license family as
the adapted file above, so the whole project is covered under one
consistent set of terms — no separate carve-out is needed for
`eventable.rb`.
