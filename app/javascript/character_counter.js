// Live character counter for form fields.
// Fields opt in via data-counter-target (name) and data-counter-max (limit).
// Matching counter span: data-counter="<name>" containing a .char-count child.
// Adds char-counter--warn at 80% and char-counter--danger at limit.

function attachCounter(field) {
  const target = field.dataset.counterTarget;
  const max = parseInt(field.dataset.counterMax, 10);
  const wrapper = document.querySelector(`[data-counter="${target}"]`);
  if (!wrapper) return;
  const count = wrapper.querySelector(".char-count");
  if (!count) return;

  function update() {
    const len = field.value.length;
    count.textContent = len;
    wrapper.classList.toggle("char-counter--danger", len >= max);
    wrapper.classList.toggle("char-counter--warn", len >= Math.floor(max * 0.8) && len < max);
  }

  field.addEventListener("input", update);
  update();
}

export function initCharacterCounters(root = document) {
  root.querySelectorAll("[data-counter-target]").forEach(attachCounter);
}
