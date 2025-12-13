import { Controller } from "@hotwired/stimulus"

// Simple show/hide toggle for filter panels or similar UI blocks
export default class extends Controller {
  static targets = ["panel", "showLabel", "hideLabel"]

  connect() {
    this.updateLabels()
  }

  toggle() {
    this.panelTargets.forEach((panel) => {
      panel.classList.toggle("hidden")
    })
    this.updateLabels()
  }

  updateLabels() {
    const isHidden = this.panelTargets.every((panel) => panel.classList.contains("hidden"))

    this.showLabelTargets.forEach((label) => {
      label.classList.toggle("hidden", !isHidden)
    })

    this.hideLabelTargets.forEach((label) => {
      label.classList.toggle("hidden", isHidden)
    })
  }
}
