import "@hotwired/turbo"
import "@rails/activestorage"
import "trix"
import "@rails/actiontext"
import "lexxy"
import "lexxy_config"
import { initCharacterCounters } from "character_counter"

// Re-init counters on full page load and on turbo-frame renders.
document.addEventListener("turbo:load", () => initCharacterCounters());
document.addEventListener("turbo:frame-render", (e) => initCharacterCounters(e.target));
