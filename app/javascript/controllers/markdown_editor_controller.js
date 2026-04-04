import { Controller } from "@hotwired/stimulus"
import Tribute from "tributejs"

export default class extends Controller {
  static targets = ["input", "fileInput"]

  connect() {
    this.loadEmojis()
  }

  disconnect() {
    if (this.tribute) {
      this.tribute.detach(this.inputTarget)
    }
  }

  handleButtonClick() {
    this.fileInputTarget.click()
  }

  handleFileSelect(e) {
    const file = e.target.files[0]
    if (file) this.uploadImage(file)
    e.target.value = ""
  }

  handlePaste(e) {
    const file = this.findImage(e.clipboardData?.files)
    if (!file) return
    e.preventDefault()
    this.uploadImage(file)
  }

  handleDrop(e) {
    e.preventDefault()
    const file = this.findImage(e.dataTransfer?.files)
    if (file) this.uploadImage(file)
  }

  handleDragover(e) {
    e.preventDefault()
  }

  async uploadImage(file) {
    const textarea = this.inputTarget
    const placeholder = "![Uploading image...]()"
    const start = textarea.selectionStart
    const before = textarea.value.substring(0, start)
    const after = textarea.value.substring(textarea.selectionEnd)

    textarea.value = before + placeholder + after
    textarea.selectionStart = textarea.selectionEnd = start + placeholder.length

    const token = document.querySelector('meta[name="csrf-token"]')?.content
    const formData = new FormData()
    formData.append("file", file)

    try {
      const response = await fetch("/admin/uploads", {
        method: "POST",
        headers: { "X-CSRF-Token": token || "" },
        body: formData
      })

      if (!response.ok) {
        const data = await response.json()
        throw new Error(data.error || "Upload failed")
      }

      const { url, filename } = await response.json()
      const markdown = `![${filename}](${url})`
      textarea.value = textarea.value.replace(placeholder, markdown)
    } catch (error) {
      console.error("Image upload failed:", error)
      textarea.value = textarea.value.replace(placeholder, "")
    }
  }

  findImage(files) {
    if (!files) return null
    return Array.from(files).find(f => f.type.startsWith("image/"))
  }

  async loadEmojis() {
    try {
      const response = await fetch("/admin/emojis.json")
      const emojis = await response.json()

      const values = Object.entries(emojis).map(([ key, value ]) => ({
        key,
        value: `${key}:`,
        display: `${value} ${key}`
      }))

      this.tribute = new Tribute({
        trigger: ":",
        values,
        lookup: "key",
        fillAttr: "value",
        menuItemTemplate: (item) =>
          `<span class="tribute-emoji">${item.original.display}</span>`,
        noMatchTemplate: () => null,
        requireLeadingSpace: false
      })

      this.tribute.attach(this.inputTarget)
    } catch (e) {
      console.error("Failed to load emojis for autocomplete", e)
    }
  }
}
