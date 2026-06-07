import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  // フォームが送信されたときに呼ばれるメソッド
  submit(event) {
    // フラッシュメッセージ領域をクリアする
    const flashContainer = document.getElementById("flash");
    if (flashContainer) {
      flashContainer.innerHTML = "";
      flashContainer.className = "";
    }

    // フォーム送信後にモーダルを閉じる
    this.close();
  }

  connect() {
    const backdrop = document.createElement("div");
    backdrop.className = "modal-backdrop in"; // 暗い背景
    document.body.appendChild(backdrop);
    document.body.classList.add("modal-open"); // スクロール停止
    backdrop.addEventListener("click", () => this.close());
    this.backdrop = backdrop; // close()で使うために保存

    this.element.addEventListener("click", (event) => {
      if (event.target === this.element) {
        this.close();
      }
    });
  }

  // モーダルを閉じるメソッド
  close() {
    this.backdrop.remove(); // バックドロップを削除
    document.body.classList.remove("modal-open"); // スクロール再開
    this.element.remove(); // モーダルの要素を削除
  }
}
