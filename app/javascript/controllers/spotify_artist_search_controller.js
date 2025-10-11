import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["query", "results", "name", "spotifyId", "imageUrl", "preview"]

  connect() {
    this.minLen = 3
    this.abortController = null
    this.clearResults()
    this.initializePreview()
    this._onClickOutside = (e) => {
      if (!this.element.contains(e.target)) this.clearResults()
    }
    document.addEventListener("click", this._onClickOutside)
  }

  disconnect() {
    if (this.abortController) this.abortController.abort()
    document.removeEventListener("click", this._onClickOutside)
  }

  onSearch(event) {
    event?.preventDefault()
    const q = this.queryTarget.value.trim()
    if (q.length < this.minLen) return this.clearResults()
    this.search(q)
  }

  async search(q) {
    try {
      if (this.abortController) this.abortController.abort()
      this.abortController = new AbortController()

      // loading表示（任意）
      this.resultsTarget.innerHTML = `<div class="px-3 py-2 text-sm text-slate-500">検索中...</div>`
      this.resultsTarget.classList.remove("hidden")

      const url = `/admin/spotify/search?q=${encodeURIComponent(q)}&market=JP`
      const res = await fetch(url, {
        headers: { "Accept": "application/json" },
        signal: this.abortController.signal
      })
      if (!res.ok) throw new Error(`HTTP ${res.status}`)
      const data = await res.json()
      this.renderResults(data.artists || [])
    } catch (e) {
      if (e.name === "AbortError") return
      // 失敗時の簡易表示（任意）
      this.resultsTarget.innerHTML = `<div class="px-3 py-2 text-sm text-slate-500">取得に失敗しました</div>`
      this.resultsTarget.classList.remove("hidden")
    }
  }

  renderResults(artists) {
    if (!artists.length) return this.clearResults()

    this.resultsTarget.setAttribute("role", "listbox")
    this.resultsTarget.innerHTML = artists.map((a, idx) => {
      const img = a.image_url
        ? `<img src="${a.image_url}" class="h-10 w-10 object-cover rounded mr-3" alt="">`
        : `<div class="h-10 w-10 bg-slate-200 rounded mr-3"></div>`
      const genres = (a.genres || []).slice(0, 3).join(", ")
      return `
        <button type="button" role="option" aria-selected="false"
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

    this.resultsTarget.querySelectorAll("button[role=option]").forEach(btn => {
      btn.addEventListener("click", (ev) => {
        const index = Number(ev.currentTarget.dataset.index)
        this.applySelection(artists[index])
      }, { once: true })
    })
  }

  applySelection(a) {
    if (this.nameTarget.value.trim() === "" && a.name) {
      this.nameTarget.value = a.name
    }
    if (a.id) this.spotifyIdTarget.value = a.id
    if (a.image_url) {
      this.imageUrlTarget.value = a.image_url
      this.previewTarget.src = a.image_url
      this.previewTarget.classList.remove("hidden")
    } else {
      this.imageUrlTarget.value = ""
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
    return (s || "").replace(/[&<>"']/g, m => ({
      '&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'
    }[m]))
  }
}