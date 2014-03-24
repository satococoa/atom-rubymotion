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
      list = atom.syntax.propertiesForScope([".source.rubymotion"], "snippets")
      keys = []
      for item in list
        keys.push _.keys(item.snippets)
      @snippetPrefixes = _.uniq(_.flatten(keys))
      @snippetPrefixes.sort (word1, word2) ->
        word1.toLowerCase().localeCompare(word2.toLowerCase())
      @autocompleteViews.forEach (v) => v.snippetPrefixes = @snippetPrefixes

  deactivate: ->
    @editorSubscription?.off()
    @editorSubscription = null
    @autocompleteViews.forEach (autocompleteView) -> autocompleteView.remove()
    @autocompleteViews = []

  serialize: ->
