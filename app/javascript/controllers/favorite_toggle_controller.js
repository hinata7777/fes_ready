import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "icon" ]
  static values = {
    url: String,
    favorited: Boolean,
    heartSrc: String,
    heartFilledSrc: String
  }

  toggle(event) {
    event.preventDefault()
    const method = this.favoritedValue ? "DELETE" : "POST"
    const csrfToken = document.querySelector("meta[name='csrf-token']")?.getAttribute("content")

    fetch(this.urlValue, {
      method,
      headers: {
        "X-CSRF-Token": csrfToken,
        "Accept": "application/json"
      },
      credentials: "same-origin"
    }).then(async (response) => {
      if (!response.ok) {
        const body = await response.json().catch(() => ({}))
        throw new Error(body.error || "お気に入りの更新に失敗しました")
      }
      return response.json()
    }).then((body) => {
      this.favoritedValue = !!body.favorited
      this.refreshIcon()
      this.pulse()
    }).catch((error) => {
      // 簡易エラー表示（UIにトーストがあれば差し替え）
      alert(error.message)
    })
  }

  favoritedValueChanged() {
    this.refreshIcon()
  }

  refreshIcon() {
    if (!this.hasIconTarget) return
    const src = this.favoritedValue ? this.heartFilledSrcValue : this.heartSrcValue
    const alt = this.favoritedValue ? "お気に入り解除" : "お気に入り登録"
    this.iconTarget.src = src
    this.iconTarget.alt = alt
  }

  pulse() {
    this.element.classList.remove("favorite-pulse")
    // 再トリガのためのリフロー
    void this.element.offsetWidth
    this.element.classList.add("favorite-pulse")
  }
}
