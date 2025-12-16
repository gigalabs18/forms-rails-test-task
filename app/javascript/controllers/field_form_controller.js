// app/javascript/controllers/field_form_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "fieldTypeSelect",
    "optionsContainer",
    "optionsHint",
    "optionsRepeater"
  ]

  connect() {
    this.updateOptionsVisibility();
    this.updateRemoveStates();
  }

  // Toggle options section based on field type
  updateOptionsVisibility() {
    const isSelect = this.fieldTypeSelectTarget.value === 'select';
    if (this.hasOptionsContainerTarget) {
      this.optionsContainerTarget.style.display = isSelect ? '' : 'none';
    }
    if (this.hasOptionsHintTarget) {
      this.optionsHintTarget.style.display = isSelect ? '' : 'none';
    }
  }

  // Add option row for existing field options
  addOption(event) {
    event.preventDefault();
    let optionIndex = this.optionsRepeaterTarget.children.length; // Use current count for index
    const row = document.createElement('div');
    row.className = 'flex items-center gap-2 option-row'; // Added option-row class for consistency
    row.innerHTML = `
      <input type="text" name="options[${optionIndex}][label]" class="input flex-1" placeholder="Label">
      <input type="text" name="options[${optionIndex}][value]" class="input flex-1" placeholder="Value (optional)">
      <button type="button" class="btn btn-danger btn-sm shrink-0" data-action="field-form#removeOption">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 0 0 1-2-2L5 6"/><path d="M10 11v6"/><path d="M14 11v6"/><path d="M9 6V4a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v2"/></svg>
        Remove
      </button>`;
    this.optionsRepeaterTarget.appendChild(row);
    this.updateRemoveStates();
  }

  // Remove option row for existing field options
  removeOption(event) {
    event.preventDefault();
    const row = event.target.closest('.option-row');
    if (row && this.optionsRepeaterTarget.children.length > 1) {
      row.remove();
      this.updateRemoveStates();
    } else if (row) { // If only one row, clear its inputs
      row.querySelectorAll('input').forEach(function(i){ i.value = ''; });
      this.updateRemoveStates(); // Still update in case it affects other logic
    }
  }

  // Update disabled state of remove buttons
  updateRemoveStates() {
    const rows = this.optionsRepeaterTarget.querySelectorAll('.option-row');
    rows.forEach((row) => {
      const removeButton = row.querySelector('[data-action="field-form#removeOption"]');
      if (removeButton) {
        removeButton.disabled = (rows.length === 1);
      }
    });
  }
}