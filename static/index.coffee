init = () ->
  # Set editor 1 for Assembly editing
  asm_editor = ace.edit("asm_editor")
  asm_session = asm_editor.getSession()
  asm_editor.setTheme "ace/theme/monokai"
  asm_session.setMode "ace/mode/asm"
  document.getElementById("asm_editor").style.fontSize = "12pt"

  # Set editor 2 for Hack binary editing
  hack_editor = ace.edit("hack_editor")
  hack_session = hack_editor.getSession()
  hack_editor.setTheme "ace/theme/monokai"
  hack_session.setMode "ace/mode/hack"
  document.getElementById("hack_editor").style.fontSize = "12pt"
  hack_editor.renderer.setShowGutter false

  # Synchronize scrollbars - http://stackoverflow.com/a/14751893/2168416
  asm_session.on "changeScrollTop", (scroll) ->
    hack_session.setScrollTop parseInt(scroll) or 0
    return

  hack_session.on "changeScrollTop", (scroll) ->
    asm_session.setScrollTop parseInt(scroll) or 0
    return

  # Setup Backbone model(s)
  Instruction = Backbone.Model.extend
    defaults: 
      line_num: null
      type: null
      dest: null
      comp: null
      jump: null
      sym: null
      label: null

  AsmFile = Backbone.Collection.extend
    model: Instruction

  window.code = new AsmFile
  window.asm_session = asm_session

  code.on "add", () ->
    console.log "added"

  code.on "change", () ->
    console.log "change"

  for row in [0..asm_session.getLength()]
    tokens = asm_session.getTokens(row)
    inst = new Instruction
    inst.set {line_num: row}
    parseLine tokens, inst
    code.add inst

  # Live parsing
  asm_session.on "change", (e) ->
    row = e.data.range.start.row
    # console.log(row)
    tokens = asm_session.getTokens(row)
    # console.log(line)
    inst = parseLine tokens, code.at(row)
    # code.at(row).set(inst)
    console.log(inst.attributes)


parseLine = (tokens, inst) ->
  tokensearch = (token, regex) ->
    token.type.search(regex) > -1

  # TODO: handle deletions of attributes
  for t in tokens
    if tokensearch(t, /\bdest\b/)
      inst.set {dest: t.value}
    else if tokensearch(t, /\bcomp\b/)
      inst.set {type: "C", comp: t.value}
    else if tokensearch(t, /\bjump\b/)
      inst.set {jump: t.value}
    else if tokensearch(t, /\baddress_op\b/)
      inst.set {type: "A"}
    else if tokensearch(t, /\bsymbol\b/)
      inst.set {sym: t.value}
      inst.set {type: "label"} if tokensearch(t, /\blabel\b/)
  return inst


# Tokenizer = require("ace/tokenizer").Tokenizer
# ASM = require("ace/mode/asm_highlight_rules")
# asm_highlight_rules = new ASM.AsmHighlightRules
# tokenizer = new Tokenizer(asm_highlight_rules.$rules)

init()