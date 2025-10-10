import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["query", "results", "name", "spotifyId", "imageUrl", "preview"]

  connect() {
    this.clearResults()
    this.minLen = 3
    this.abortController = null
    this.initializePreview()
  }

  onSearch(event) {
    event?.preventDefault()
    const q = this.queryTarget.value.trim()
    if (q.length < this.minLen) {
      this.clearResults()
      return
    }
    this.search(q)
  }

  async search(q) {
    try {
      // 中断制御（連続入力で前リクエストをキャンセル）
      if (this.abortController) this.abortController.abort()
      this.abortController = new AbortController()

      const url = `/admin/spotify/search?q=${encodeURIComponent(q)}`
      const res = await fetch(url, { headers: { "Accept": "application/json" }, signal: this.abortController.signal })
      if (!res.ok) throw new Error(`HTTP ${res.status}`)
      const data = await res.json()
      this.renderResults(data.artists || [])
    } catch (e) {
      if (e.name === "AbortError") return
      this.renderResults([])
    }
  }

  renderResults(artists) {
    if (!artists.length) {
      this.clearResults()
      return
    }
    this.resultsTarget.innerHTML = artists.map((a, idx) => {
      const img = a.image_url ? `<img src="${a.image_url}" class="h-10 w-10 object-cover rounded mr-3" alt="">` : `<div class="h-10 w-10 bg-slate-200 rounded mr-3"></div>`
      const genres = (a.genres || []).slice(0, 3).join(", ")
      return `
        <button type="button"
                data-index="${idx}"
                class="w-full flex items-center px-3 py-2 hover:bg-slate-50 focus:bg-slate-50">
          ${img}
          <div class="text-left">
            <div class="font-semibold">${this.escape(a.name)}</div>
            <div class="text-xs text-slate-500">${this.escape(genres)}${a.popularity ? ` ・pop:${a.popularity}` : ""}</div>
          </div>
          <span class="ml-auto text-xs text-slate-400">${a.id}</span>
        </button>
      `
    }).join("")
    this.resultsTarget.classList.remove("hidden")
    this.resultsTarget.querySelectorAll("button").forEach(btn => {
      btn.addEventListener("click", (ev) => {
        const index = Number(ev.currentTarget.dataset.index)
        const a = artists[index]
        this.applySelection(a)
      })
    })
  }

  applySelection(a) {
    // 選択内容をフォームに反映
    if (a.name) this.nameTarget.value = a.name
    if (a.id) this.spotifyIdTarget.value = a.id
    if (a.image_url) {
      this.imageUrlTarget.value = a.image_url
      this.previewTarget.src = a.image_url
      this.previewTarget.classList.remove("hidden")
    } else {
      this.previewTarget.src = ""
      this.previewTarget.classList.add("hidden")
    }
    this.clearResults()
  }

  clearResults() {
    this.resultsTarget.innerHTML = ""
    this.resultsTarget.classList.add("hidden")
  }

  initializePreview() {
    const url = this.imageUrlTarget?.value?.trim()
    if (url) {
      this.previewTarget.src = url
      this.previewTarget.classList.remove("hidden")
    }
  }

  escape(s) {
    return (s || "").replace(/[&<>"']/g, m => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m]))
  }
}
