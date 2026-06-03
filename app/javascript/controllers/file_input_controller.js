import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["field", "name"];

  // ファイルが選択されたとき、ファイル名を表示欄に反映する
  update() {
    const file = this.fieldTarget.files[0];
    this.nameTarget.value = file ? file.name : "";
  }
}
