_ = require 'underscore-plus'
RubyMotionAutocompleteView = require './rubymotion-autocomplete-view'

module.exports =
  autocompleteViews: []
  editorSubscription: null
  snippetPrefixes: []

  activate: (state) ->
    @editorSubscription = atom.workspaceView.eachEditorView (editor) =>
      if editor.attached and not editor.mini
        autocompleteView = new RubyMotionAutocompleteView(editor)
        autocompleteView.snippetPrefixes = @snippetPrefixes
        editor.on 'editor:will-be-removed', =>
          autocompleteView.remove() unless autocompleteView.hasParent()
          _.remove(@autocompleteViews, autocompleteView)
        @autocompleteViews.push(autocompleteView)

    atom.packages.on 'snippets:loaded', =>
      @snippetPrefixes = @collectSnippets()
      @autocompleteViews.forEach (v) => v.snippetPrefixes = @snippetPrefixes

  collectSnippets: ->
    snippets = atom.syntax.propertiesForScope([".source.rubymotion"], "snippets")
    keys = []
    for item in snippets
      keys.push _.keys(item.snippets)
    _.uniq(_.flatten(keys)).sort (word1, word2) ->
      word1.toLowerCase().localeCompare(word2.toLowerCase())

  deactivate: ->
    @editorSubscription?.off()
    @editorSubscription = null
    @autocompleteViews.forEach (autocompleteView) -> autocompleteView.remove()
    @autocompleteViews = []

  serialize: ->
