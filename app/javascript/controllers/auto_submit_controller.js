import { Controller } from "@hotwired/stimulus"

// チェックボックスなどが変わったら、親フォームを即送信するだけのコントローラ
export default class extends Controller {
  submit(event) {
    const form = event.target.form
    if (form) form.requestSubmit()
  }
}
