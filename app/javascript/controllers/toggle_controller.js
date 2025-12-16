// app/javascript/controllers/toggle_controller.js
import { Controller } from "@hotwired/stimulus"

// This controller can be used to toggle the visibility of elements.
// It expects a "toggleable" target and can have one or more "toggler" elements.
export default class extends Controller {
  static targets = ["toggleable", "toggler"]

  connect() {
    // If the toggleable element is visible on connect (e.g. due to form errors),
    // hide the toggler button.
    if (!this.toggleableTarget.classList.contains('hidden')) {
      this.hideToggler();
    }
  }

  // Action to show the toggleable element and hide the button that triggered it.
  show() {
    this.toggleableTarget.classList.remove('hidden');
    this.toggleableTarget.style.display = '';
    this.hideToggler();
  }

  // Hides all elements marked as a toggler target.
  hideToggler() {
    this.togglerTargets.forEach(el => el.classList.add('hidden'));
  }
}