_ = require 'underscore-plus'
RubyMotionAutocompleteView = require './rubymotion-autocomplete-view'
Snippet = require(atom.packages.resolvePackagePath('snippets') + '/lib/snippet')
Snippets = require(atom.packages.resolvePackagePath('snippets') + '/lib/snippets')

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

    @collectSnippets (prefixes) =>
      @snippetPrefixes = prefixes
      @autocompleteViews.forEach (v) => v.snippetPrefixes = @snippetPrefixes

  collectSnippets: (callback) ->
    path = atom.packages.resolvePackagePath('RubyMotion') + '/snippets/cocoatouch'
    Snippets.loadSnippetsDirectory path, ->
      snippets = atom.syntax.propertiesForScope([".source.rubymotion"], "snippets")
      keys = []
      for item in snippets
        for k in _.keys(item.snippets)
          keys.push k
      keys = keys.sort (word1, word2) ->
        word1.toLowerCase().localeCompare(word2.toLowerCase())
      callback keys

  deactivate: ->
    @editorSubscription?.off()
    @editorSubscription = null
    @autocompleteViews.forEach (autocompleteView) -> autocompleteView.remove()
    @autocompleteViews = []

  serialize: ->
