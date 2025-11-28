import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // ターゲット定義: HTML側の data-*-target で参照する要素
  static targets = [
    "modal",
    "itemsContainer",
    "existingItemTemplate",
    "newItemTemplate",
    "newItemName",
    "newItemDescription",
    "emptyState"
  ]

  static values = {
    nextPosition: Number
  }

  connect() {
    if (!this.hasNextPositionValue) {
      const existingCount = this.itemsContainerTarget.querySelectorAll("[data-nested-form-wrapper]").length
      this.nextPositionValue = existingCount
    }
  }

  // モーダルを開く
  openModal(event) {
    event.preventDefault()
    this.modalTarget.classList.remove("hidden")
    document.body.classList.add("overflow-hidden")
  }

  // モーダルを閉じる
  closeModal(event) {
    if (event) event.preventDefault()
    this.modalTarget.classList.add("hidden")
    document.body.classList.remove("overflow-hidden")
  }

  // テンプレから持ち物を追加
  addExistingItem(event) {
    event.preventDefault()
    const button = event.currentTarget
    const itemId = button.dataset.itemId
    const existingRow = this.findRowByItemId(itemId)
    if (existingRow) {
      this.reviveRow(existingRow)
      this.closeModal()
      return
    }

    const itemDescription = button.dataset.itemDescription || ""
    const html = this.buildRowHtml(this.existingItemTemplateTarget.innerHTML, {
      index: this.generateIndex(),
      position: this.nextPosition(),
      itemId,
      itemName: button.dataset.itemName || "",
      itemDescription,
      itemNote: itemDescription
    })
    this.itemsContainerTarget.insertAdjacentHTML("beforeend", html)
    this.hideEmptyState()
    this.closeModal()
  }

  // 新規持ち物をモーダルから追加
  submitNewItem(event) {
    event.preventDefault()
    const name = this.newItemNameTarget.value.trim()
    const description = this.newItemDescriptionTarget.value.trim()
    if (!name) return

    const html = this.buildRowHtml(this.newItemTemplateTarget.innerHTML, {
      index: this.generateIndex(),
      position: this.nextPosition(),
      itemName: name,
      itemDescription: description,
      itemNote: description
    })
    this.itemsContainerTarget.insertAdjacentHTML("beforeend", html)
    this.hideEmptyState()
    this.newItemNameTarget.value = ""
    this.newItemDescriptionTarget.value = ""
    this.closeModal()
  }

  // 行を削除（_destroyを立てて非表示）
  removeItem(event) {
    event.preventDefault()
    const wrapper = event.currentTarget.closest("[data-nested-form-wrapper]")
    if (!wrapper) return

    const destroyField = wrapper.querySelector("[data-destroy-field]")
    if (destroyField) {
      destroyField.value = "1"
      wrapper.classList.add("hidden")
    } else {
      wrapper.remove()
    }
    this.updateEmptyState()
  }

  stopPropagation(event) {
    event.stopPropagation()
  }

  // Helpers
  // item_id で既存行を探す
  findRowByItemId(itemId) {
    if (!itemId) return null
    try {
      return this.itemsContainerTarget.querySelector(`[data-item-id='${CSS.escape(itemId)}']`)
    } catch (e) {
      return null
    }
  }

  // 削除済み行を復活
  reviveRow(wrapper) {
    const destroyField = wrapper.querySelector("[data-destroy-field]")
    if (destroyField) destroyField.value = "0"
    wrapper.classList.remove("hidden")
    this.hideEmptyState()
  }

  // position用カウンタ
  nextPosition() {
    const pos = this.nextPositionValue || 0
    this.nextPositionValue = pos + 1
    return pos
  }

  // テンプレ用インデックス生成
  generateIndex() {
    return `${Date.now().toString(36)}${Math.random().toString(36).slice(2, 6)}`
  }

  // テンプレ文字列に値を埋め込む
  buildRowHtml(template, { index, position, itemId = "", itemName = "", itemDescription = "", itemNote = "" }) {
    return template
      .replaceAll("__INDEX__", index)
      .replaceAll("__POSITION__", position)
      .replaceAll("__ITEM_ID__", this.escape(itemId))
      .replaceAll("__ITEM_NAME__", this.escape(itemName))
      .replaceAll("__ITEM_DESCRIPTION__", this.escape(itemDescription || ""))
      .replaceAll("__ITEM_NOTE__", this.escape(itemNote || ""))
  }

  escape(value) {
    const div = document.createElement("div")
    div.textContent = value
    return div.innerHTML
  }

  // 表示されている行
  visibleRows() {
    return Array.from(this.itemsContainerTarget.querySelectorAll("[data-nested-form-wrapper]")).filter(
      (row) => !row.classList.contains("hidden")
    )
  }

  // 空状態を隠す
  hideEmptyState() {
    if (this.hasEmptyStateTarget) this.emptyStateTarget.classList.add("hidden")
  }

  // 行がゼロなら空状態を表示
  updateEmptyState() {
    if (!this.hasEmptyStateTarget) return
    if (this.visibleRows().length === 0) {
      this.emptyStateTarget.classList.remove("hidden")
    }
  }
}
