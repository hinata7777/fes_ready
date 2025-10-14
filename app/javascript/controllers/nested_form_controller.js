import { Controller } from "@hotwired/stimulus"

// <template>のHTMLを複製して NEW_RECORD をユニークIDに置換→挿入
export default class extends Controller {
  static targets = ["container", "template"]

  add(e) {
    e.preventDefault()
    const html = this.templateTarget.innerHTML
    const uid  = Date.now().toString()
    const content = html.replaceAll("NEW_RECORD", uid)
    this.containerTarget.insertAdjacentHTML("beforeend", content)
  }

  remove(e) {
    e.preventDefault()
    const wrapper = e.currentTarget.closest("[data-nested-form-wrapper]")
    const destroyField = wrapper.querySelector("input[type='hidden'][name$='[_destroy]']")
    if (destroyField) destroyField.value = "1"       // _destroy=1 で削除
    wrapper.classList.add("hidden")                  // 見た目は即非表示
  }
}