exec = require('child_process').exec

module.exports =
  activate: (state) ->
    atom.workspaceView.command "rubymotion:dash", => @dash()

  deactivate: ->

  serialize: ->

  dash: ->
    editor = atom.workspace.getActiveEditor()
    editor.selectWord()
    query = editor.getSelectedText()
    return if query is ""
    exec "open dash://rubymotion:#{query}"
