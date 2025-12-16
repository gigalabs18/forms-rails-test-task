// app/javascript/controllers/form_show_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "publicLinkInput",
    "copyButton",
    "addQuestionFab",
    "addQuestionCard",
    "addQuestionForm",
    "newFieldType",
    "initialOptionsSection",
    "initialOptionsRepeater",
    "closeAddQuestionButton"
  ]

  connect() {
    this.addQuestionCardTarget.classList.add('hidden');
    this.addQuestionCardTarget.style.display = 'none';
    this.updateOptionsVisibility();
    this.updateRemoveStates();
  }

  // Copy Link functionality
  copyLink() {
    const el = this.publicLinkInputTarget;
    navigator.clipboard.writeText(el.value).then(() => {
      const originalText = this.copyButtonTarget.textContent;
      this.copyButtonTarget.textContent = 'Copied';
      this.copyButtonTarget.disabled = true;
      setTimeout(() => {
        this.copyButtonTarget.textContent = originalText;
        this.copyButtonTarget.disabled = false;
      }, 1200);
    });
  }

  // Toggle Add Question Card
  toggleAddQuestionCard() {
    const expanded = this.addQuestionFabTarget.getAttribute('aria-expanded') === 'true';
    this.addQuestionFabTarget.setAttribute('aria-expanded', (!expanded).toString());

    if (expanded) {
      this.addQuestionCardTarget.classList.add('hidden');
      this.addQuestionCardTarget.style.display = 'none';
    } else {
      this.addQuestionCardTarget.classList.remove('hidden');
      this.addQuestionCardTarget.style.display = '';
      setTimeout(() => {
        const input = this.addQuestionFormTarget.querySelector('#newFieldLabel');
        if (input) input.focus();
      }, 50);
      this.updateOptionsVisibility();
    }
  }

  // Handle field type change for initial options
  updateOptionsVisibility() {
    if (this.hasNewFieldTypeTarget) {
      if (this.newFieldTypeTarget.value === 'select') {
        this.initialOptionsSectionTarget.classList.remove('hidden');
        this.initialOptionsSectionTarget.style.display = 'block';
      } else {
        this.initialOptionsSectionTarget.classList.add('hidden');
        this.initialOptionsSectionTarget.style.display = 'none';
      }
    }
  }

  // Add option row for initial options
  addOption(event) {
    event.preventDefault();
    let optionIndex = this.initialOptionsRepeaterTarget.children.length; // Use current count for index
    const row = document.createElement('div');
    row.className = 'grid grid-cols-5 gap-2 items-end option-row';
    row.innerHTML = `
      <div class="col-span-3">
        <input name="options[${optionIndex}][label]" class="input" placeholder="e.g. Option ${optionIndex + 1}" />
      </div>
      <div>
        <input name="options[${optionIndex}][value]" class="input" placeholder="value" />
      </div>
      <div class="flex gap-2">
        <button type="button" class="btn btn-secondary" data-action="form-show#addOption">Add</button>
        <button type="button" class="btn btn-ghost" data-action="form-show#removeOption">Remove</button>
      </div>`;
    this.initialOptionsRepeaterTarget.appendChild(row);
    this.updateRemoveStates();
  }

  // Remove option row for initial options
  removeOption(event) {
    event.preventDefault();
    const row = event.target.closest('.option-row');
    if (row && this.initialOptionsRepeaterTarget.children.length > 1) {
      row.remove();
      this.updateRemoveStates();
    }
  }

  // Update disabled state of remove buttons
  updateRemoveStates() {
    const rows = this.initialOptionsRepeaterTarget.querySelectorAll('.option-row');
    rows.forEach((row) => {
      const removeButton = row.querySelector('[data-action="form-show#removeOption"]');
      if (removeButton) {
        removeButton.disabled = (rows.length === 1);
      }
    });
  }

  // Handle turbo:submit-end for add question form
  addQuestionFormSubmitEnd(event) {
    if (event.detail && event.detail.success) {
      this.addQuestionFormTarget.reset();
      this.addQuestionFabTarget.setAttribute('aria-expanded', 'false');
      this.addQuestionCardTarget.classList.add('hidden');
      this.addQuestionCardTarget.style.display = 'none';

      const container = document.getElementById('fields_table_body');
      if (container && container.lastElementChild) {
        container.lastElementChild.scrollIntoView({ behavior: 'smooth', block: 'center' });
      }

      // Reset initial options repeater
      this.initialOptionsRepeaterTarget.innerHTML = `
        <div class="grid grid-cols-5 gap-2 items-end option-row">
          <div class="col-span-3">
            <input name="options[0][label]" class="input" placeholder="e.g. Option 1" />
          </div>
          <div>
            <input name="options[0][value]" class="input" placeholder="value" />
          </div>
          <div class="flex gap-2">
            <button type="button" class="btn btn-secondary" data-action="form-show#addOption">Add</button>
            <button type="button" class="btn btn-ghost" data-action="form-show#removeOption" disabled>Remove</button>
          </div>
        </div>`;
      this.updateOptionsVisibility();
      this.updateRemoveStates();
    }
  }
}