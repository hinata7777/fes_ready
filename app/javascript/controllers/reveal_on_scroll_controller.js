import { Controller } from "@hotwired/stimulus"

// Slides cards into view when they enter the viewport
export default class extends Controller {
  static targets = ["item"]

  connect() {
    this.observer = new IntersectionObserver(this.reveal, {
      threshold: 0.25,
      rootMargin: "0px 0px -10% 0px",
    })

    this.itemTargets.forEach((item, index) => {
      item.style.transitionDelay = `${index * 80}ms`
      this.observer.observe(item)
    })
  }

  disconnect() {
    this.observer?.disconnect()
  }

  reveal = (entries) => {
    entries.forEach((entry) => {
      if (!entry.isIntersecting) return

      const element = entry.target
      element.classList.remove("opacity-0", "translate-y-6")
      element.classList.add("opacity-100", "translate-y-0")

      this.observer.unobserve(element)
    })
  }
}
