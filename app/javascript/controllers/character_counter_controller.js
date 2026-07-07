import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["field", "count"]
  static values = { max: Number }

  connect() {
    this.update()
  }

  update() {
    const len = this.fieldTarget.value.length
    this.countTarget.textContent = len
    this.element.classList.toggle("char-counter--danger", len >= this.maxValue)
    this.element.classList.toggle("char-counter--warn", len >= Math.floor(this.maxValue * 0.8) && len < this.maxValue)
  }
}
