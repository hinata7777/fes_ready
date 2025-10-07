import { Controller } from "@hotwired/stimulus"

// Controls the slide-in hamburger side menu.
export default class extends Controller {
  static targets = ["backdrop", "panel", "button"]

  connect() {
    this.isOpen = false
    // 初期表示は必ず閉じる（キャッシュ復元に備える）
    this._forceClosedDOM()

    // 戻る/進む、BFCache復帰、Turbo遷移のたびに閉じる
    this._onPopstate = () => this.close()
    this._onPageshow = (e) => { if (e.persisted) this.close() }
    this._onTurboLoad = () => this.close()

    window.addEventListener("popstate", this._onPopstate)
    window.addEventListener("pageshow", this._onPageshow)
    document.addEventListener("turbo:load", this._onTurboLoad)

    // Escで閉じる
    this._onKeydown = (e) => { if (e.key === "Escape") this.close() }
    window.addEventListener("keydown", this._onKeydown)
  }

  disconnect() {
    window.removeEventListener("popstate", this._onPopstate)
    window.removeEventListener("pageshow", this._onPageshow)
    document.removeEventListener("turbo:load", this._onTurboLoad)
    window.removeEventListener("keydown", this._onKeydown)
  }

  toggle() {
    this.isOpen ? this.close() : this.open()
  }

  open() {
    if (this.isOpen) return
    this.isOpen = true
    this._setExpanded(true)
    this.showBackdrop()
    this.showPanel()
    document.body.classList.add("overflow-hidden")
  }

  close() {
    if (!this.isOpen) {
      // 開いていなくても DOM を閉じ状態に寄せておく
      this._forceClosedDOM()
      return
    }
    this.isOpen = false
    this._setExpanded(false)
    this.hideBackdrop()
    this.hidePanel()
    document.body.classList.remove("overflow-hidden")

    // 履歴に開閉状態を残さない（URLは変えない）
    try { history.replaceState(history.state, "", location.href) } catch (_) {}
  }

  // — helpers —
  _setExpanded(value) {
    if (this.hasButtonTarget) {
      this.buttonTarget.setAttribute("aria-expanded", value ? "true" : "false")
    }
  }

  _forceClosedDOM() {
    // DOMを確実に「閉じた見た目」へ
    if (this.hasBackdropTarget) {
      this.backdropTarget.classList.add("hidden", "opacity-0")
      this.backdropTarget.classList.remove("opacity-100")
    }
    if (this.hasPanelTarget) {
      this.panelTarget.classList.add("translate-x-full")
    }
    this._setExpanded(false)
    document.body.classList.remove("overflow-hidden")
  }

  showBackdrop() {
    const el = this.backdropTarget
    el.classList.remove("hidden")
    requestAnimationFrame(() => {
      el.classList.remove("opacity-0")
      el.classList.add("opacity-100")
    })
  }

  hideBackdrop() {
    const el = this.backdropTarget
    el.classList.remove("opacity-100")
    el.classList.add("opacity-0")
    this._waitForTransition(el, () => {
      if (!this.isOpen) el.classList.add("hidden")
    })
  }

  showPanel() {
    const el = this.panelTarget
    requestAnimationFrame(() => el.classList.remove("translate-x-full"))
  }

  hidePanel() {
    this.panelTarget.classList.add("translate-x-full")
  }

  _waitForTransition(element, callback) {
    const handler = () => { element.removeEventListener("transitionend", handler); callback() }
    element.addEventListener("transitionend", handler, { once: true })
  }
}