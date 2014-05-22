_ = require 'underscore-plus'
RubyMotionAutocompleteView = require './rubymotion-autocomplete-view'
# FIXME: dirty hack for wrong module path detection on `apm test`
snippetsModPath = _.find atom.packages.getAvailablePackagePaths(), (path) ->
  path.match /\/snippets$/
Snippets = require snippetsModPath
childProcess = require 'child_process'

module.exports =
  configDefaults:
    lookUpInDashKeyword: 'ios'

  autocompleteViews: []
  editorSubscription: null
  snippetPrefixes: []

  activate: (state) ->
    @editorSubscription = atom.workspaceView.eachEditorView (editor) =>
      if editor.attached
        @enableAutocomplete(editor)

    @collectSnippets (prefixes) =>
      @snippetPrefixes = prefixes
      @autocompleteViews.forEach (v) => v.snippetPrefixes = @snippetPrefixes

    atom.workspaceView.command 'rubymotion:look-up-in-dash', =>
      editor = atom.workspace.getActiveEditor()
      @lookUpInDash(editor) if editor?

  enableAutocomplete: (editor) ->
    autocompleteView = new RubyMotionAutocompleteView(editor)
    autocompleteView.snippetPrefixes = @snippetPrefixes
    editor.on 'editor:will-be-removed', =>
      autocompleteView.remove() unless autocompleteView.hasParent()
      _.remove(@autocompleteViews, autocompleteView)
    @autocompleteViews.push(autocompleteView)

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

  lookUpInDash: (editor) ->
    word = editor.getWordUnderCursor(includeNonWordCharacters: false)
    return if word is ''
    keyword = atom.config.get('RubyMotion.lookUpInDashKeyword')
    url = "dash://#{keyword}:#{word}"
    childProcess.exec "open #{url}"

  deactivate: ->
    @editorSubscription?.off()
    @editorSubscription = null
    @autocompleteViews.forEach (autocompleteView) -> autocompleteView.remove()
    @autocompleteViews = []

  serialize: ->
