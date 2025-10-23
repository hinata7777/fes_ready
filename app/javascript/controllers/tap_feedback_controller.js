import { Controller } from "@hotwired/stimulus"

// Adds and removes a CSS class while a touch interaction is active so mobile taps
// feel the same as hover interactions on desktop.
export default class extends Controller {
  static values = {
    releaseDelay: { type: Number, default: 120 },
    activeClass: { type: String, default: "is-touch-active" }
  }

  connect() {
    this.handleTouchStart = this.handleTouchStart.bind(this)
    this.handleTouchEnd = this.handleTouchEnd.bind(this)
    this.handleTouchCancel = this.handleTouchCancel.bind(this)

    this.element.addEventListener("touchstart", this.handleTouchStart, { passive: true })
    this.element.addEventListener("touchend", this.handleTouchEnd, { passive: true })
    this.element.addEventListener("touchcancel", this.handleTouchCancel, { passive: true })
  }

  disconnect() {
    this.element.removeEventListener("touchstart", this.handleTouchStart)
    this.element.removeEventListener("touchend", this.handleTouchEnd)
    this.element.removeEventListener("touchcancel", this.handleTouchCancel)
    this.clearReleaseTimeout()
  }

  handleTouchStart() {
    this.clearReleaseTimeout()
    this.element.classList.add(this.activeClassValue)
  }

  handleTouchEnd() {
    this.clearReleaseTimeout()
    this.releaseTimeout = setTimeout(() => {
      this.element.classList.remove(this.activeClassValue)
      this.releaseTimeout = null
    }, this.releaseDelayValue)
  }

  handleTouchCancel() {
    this.clearReleaseTimeout()
    this.element.classList.remove(this.activeClassValue)
  }

  clearReleaseTimeout() {
    if (!this.releaseTimeout) return

    clearTimeout(this.releaseTimeout)
    this.releaseTimeout = null
  }
}
