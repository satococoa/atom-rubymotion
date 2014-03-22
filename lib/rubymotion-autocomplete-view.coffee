_ = require 'underscore-plus'
AutocompleteView = require(atom.packages.resolvePackagePath('autocomplete') + '/lib/autocomplete-view')

module.exports =
class RubyMotionAutocompleteView extends AutocompleteView
  snippetPrefixes: []

  initialize: (@editorView) ->
    super

  buildWordList: ->
    @wordList = @snippetPrefixes

  handleEvents: ->
    @list.on 'mousewheel', (event) -> event.stopPropagation()

    @editorView.on 'editor:path-changed', => @setCurrentBuffer(@editor.getBuffer())
    @editorView.command 'rubymotion-autocomplete:toggle', =>
      if @hasParent()
        @cancel()
      else
        @attach()
    @editorView.command 'rubymotion-autocomplete:next', => @selectNextItemView()
    @editorView.command 'rubymotion-autocomplete:previous', => @selectPreviousItemView()

    @filterEditorView.preempt 'textInput', ({originalEvent}) =>
      text = originalEvent.data
      unless text.match(@wordRegex)
        @confirmSelection()
        @editor.insertText(text)
        false

  confirmed: (match) ->
    @editor.getSelection().clear()
    @cancel()
    return unless match
    @replaceSelectedTextWithMatch match
    position = @editor.getCursorBufferPosition()
    @editor.setCursorBufferPosition([position.row, position.column + match.suffix.length])
    snippet = atom.syntax.propertiesForScope([".source.rubymotion"], "snippets.#{match.word}")[0].snippets[match.word]
    @editorView.trigger 'snippets:expand' if snippet?
