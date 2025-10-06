import { Controller } from "@hotwired/stimulus"

// Controls the slide-in hamburger side menu.
export default class extends Controller {
  static targets = ["backdrop", "panel", "toggle"]

  connect() {
    this.isOpen = false
  }

  toggle() {
    this.isOpen ? this.close() : this.open()
  }

  open() {
    if (this.isOpen) return
    this.isOpen = true

    if (this.hasToggleTarget) {
      this.toggleTarget.setAttribute("aria-expanded", "true")
    }
    this.showBackdrop()
    this.showPanel()
    document.body.classList.add("overflow-hidden")
  }

  close() {
    if (!this.isOpen) return
    this.isOpen = false

    if (this.hasToggleTarget) {
      this.toggleTarget.setAttribute("aria-expanded", "false")
    }
    this.hideBackdrop()
    this.hidePanel()
    document.body.classList.remove("overflow-hidden")
  }

  handleKeydown(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }

  showBackdrop() {
    const backdrop = this.backdropTarget
    backdrop.classList.remove("hidden")
    requestAnimationFrame(() => {
      backdrop.classList.remove("opacity-0")
      backdrop.classList.add("opacity-100")
    })
  }

  hideBackdrop() {
    const backdrop = this.backdropTarget
    backdrop.classList.remove("opacity-100")
    backdrop.classList.add("opacity-0")
    this.waitForTransition(backdrop, () => {
      if (!this.isOpen) {
        backdrop.classList.add("hidden")
      }
    })
  }

  showPanel() {
    const panel = this.panelTarget
    requestAnimationFrame(() => {
      panel.classList.remove("translate-x-full")
    })
  }

  hidePanel() {
    const panel = this.panelTarget
    panel.classList.add("translate-x-full")
  }

  waitForTransition(element, callback) {
    const handler = () => {
      element.removeEventListener("transitionend", handler)
      callback()
    }

    element.addEventListener("transitionend", handler, { once: true })
  }
}
