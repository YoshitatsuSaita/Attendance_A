import { Controller } from "@hotwired/stimulus";

// ユーザー一覧の「基本情報編集」アコーディオンを制御する。
// 同時に開けるのは1つまで。開いている本人のボタンを再度押すと閉じる。
export default class extends Controller {
  static targets = ["panel"];

  toggle({ params: { id } }) {
    const panel = this.panelTargets.find(
      (target) => target.dataset.userId === String(id)
    );
    if (!panel) return;

    const willOpen = panel.hidden;
    this.closeAll();
    panel.hidden = !willOpen;
  }

  closeAll() {
    this.panelTargets.forEach((panel) => {
      panel.hidden = true;
    });
  }
}
