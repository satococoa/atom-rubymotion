{View} = require 'atom'

module.exports =
class LanguageRubymotionView extends View
  @content: ->
    @div class: 'language-rubymotion overlay from-top', =>
      @div "The LanguageRubymotion package is Alive! It's ALIVE!", class: "message"

  initialize: (serializeState) ->
    atom.workspaceView.command "language-rubymotion:toggle", => @toggle()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  toggle: ->
    console.log "LanguageRubymotionView was toggled!"
    if @hasParent()
      @detach()
    else
      atom.workspaceView.append(this)
