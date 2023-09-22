import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.addEventListener("dragover", this._onDragOver.bind(this));
    this.element.addEventListener("dragenter", this._onDragEnter.bind(this));
    this.element.addEventListener("dragleave", this._onDragLeave.bind(this));
    this.element.addEventListener("drop", this._onDrop.bind(this));
  }

  disconnect() {
    this.element.removeEventListener("dragover", this._onDragOver.bind(this));
    this.element.removeEventListener("drop", this._onDrop.bind(this));
  }

  _onDragOver(event) {
    event.preventDefault();
  }

  _onDrop(event) {
    event.preventDefault();

    let dataTransfer = event.dataTransfer;
    let files = dataTransfer.files;

    this._uploadFiles(files);
  }

  _uploadFiles(files) {
   Array.from(files).forEach(file => {
    let formData = new FormData();
    formData.append("document", file);

    fetch(`/folders/${this.element.dataset.folderId}/upload`, {
      method: "POST",
      body: formData,
      headers: {
        'X-CSRF-Token': document.querySelector("meta[name='csrf-token']").content
      }
    })
    .then(response => response.json())
    .then(data => {
      this._showFlashMessage(data.status, data.message);
      setTimeout(() => {
        location.reload();
      }, 100);
    })
    .catch(error => {
      console.error("Error uploading file:", error);
    });
  });
  }

  _onDragEnter(event) {
    this.element.classList.add("dragging");
  }

  _onDragLeave(event) {
    this.element.classList.remove("dragging");
  }

  _showFlashMessage(status, message) {
    const flashContainer = document.getElementById("notice");
    let alertType = (status === "success") ? "alert-success" : "alert-danger";
    let newAlert = document.createElement("div");
    newAlert.className = `alert ${alertType} fade-out`;
    newAlert.setAttribute("data-controller", "notice");
    newAlert.textContent = message;
    flashContainer.appendChild(newAlert);
  }
}


