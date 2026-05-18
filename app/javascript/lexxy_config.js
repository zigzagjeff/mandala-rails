import * as Lexxy from "lexxy"

// CheckListExtension is part of @lexical/list, which Lexxy bundles internally.
// We access it via Lexxy's own exports to avoid a duplicate Lexical instance.
const { CheckListExtension } = Lexxy

if (CheckListExtension) {
  class CheckboxExtension extends Lexxy.Extension {
    get enabled() {
      return this.editorElement.supportsRichText
    }

    get lexicalExtension() {
      return CheckListExtension
    }
  }

  Lexxy.configure({
    global: {
      extensions: [CheckboxExtension]
    }
  })
}
