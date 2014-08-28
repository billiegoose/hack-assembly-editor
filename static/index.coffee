# Set editor 1 for Assembly editing
asm_editor = ace.edit("asm_editor")
asm_editor.setTheme "ace/theme/monokai"
asm_editor.getSession().setMode "ace/mode/asm"
document.getElementById("asm_editor").style.fontSize = "12pt"

# Set editor 2 for Hack binary editing
hack_editor = ace.edit("hack_editor")
hack_editor.setTheme "ace/theme/monokai"
hack_editor.getSession().setMode "ace/mode/hack"
document.getElementById("hack_editor").style.fontSize = "12pt"
hack_editor.renderer.setShowGutter false

# Synchronize scrollbars - http://stackoverflow.com/a/14751893/2168416
session1 = asm_editor.getSession()
session2 = hack_editor.getSession()
session1.on "changeScrollTop", (scroll) ->
  session2.setScrollTop parseInt(scroll) or 0
  return

session2.on "changeScrollTop", (scroll) ->
  session1.setScrollTop parseInt(scroll) or 0
  return

# Setup Backbone model(s)
Instruction = Backbone.Model.extend
  defaults: 
    type: null
    dest: null
    comp: null
    jump: null
    sym: null

window.bob = new Instruction

# Live parsing
Tokenizer = require("ace/tokenizer").Tokenizer
ASM = require("ace/mode/asm_highlight_rules")
asm_highlight_rules = new ASM.AsmHighlightRules
tokenizer = new Tokenizer(asm_highlight_rules.$rules)
asm_editor.getSession().on "change", (e) ->
  row = e.data.range.start.row
  # console.log(row);
  line = asm_editor.getSession().getDocument().getLine(row)
  # console.log(line);
  tokens = tokenizer.getLineTokens(line).tokens
  # console.log(tokens);
  obj =
    type: null
    dest: null
    comp: null
    jump: null
    sym: null

  tokensearch = (token, regex) ->
    token.type.search(regex) > -1

  for a in tokens
    if tokensearch(a, /\bdest\b/)
      obj.dest = a.value
    else if tokensearch(a, /\bcomp\b/)
      obj.type = "C"
      obj.comp = a.value
    else if tokensearch(a, /\bjump\b/)
      obj.jump = a.value
    else if tokensearch(a, /\baddress_op\b/)
      obj.type = "A"
    else if tokensearch(a, /\bsymbol\b/)
      obj.sym = a.value
      obj.type = "label"  if tokensearch(a, /\blabel\b/)
  console.log obj
  return

# TODO: Next, integrate 'obj' with Backbone.js