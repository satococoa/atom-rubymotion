# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.
{$, EditorView, WorkspaceView} = require 'atom'
RubyMotion = require '../lib/rubymotion'
RubyMotionAutocompleteView = require '../lib/rubymotion-autocomplete-view'
_ = require 'underscore-plus'

describe 'RubyMotion', ->
  # see: https://github.com/atom/autocomplete
  describe 'autocompletion', ->
    [activationPromise] = []

    beforeEach ->
      atom.workspaceView = new WorkspaceView
      atom.workspaceView.openSync('sample.rb')
      atom.workspaceView.simulateDomAttachment()
      activationPromise = atom.packages.activatePackage('RubyMotion')

    describe '@activate()', ->
      it "activates autocomplete on all existing and future editors (but not on autocomplete's own mini editor)", ->

        spyOn(RubyMotionAutocompleteView.prototype, 'initialize').andCallThrough()
        expect(
          RubyMotionAutocompleteView.prototype.initialize
        ).not.toHaveBeenCalled()

        leftEditor = atom.workspaceView.getActiveView()
        rightEditor = leftEditor.splitRight()

        leftEditor.trigger 'rubymotion-autocomplete:toggle'

        waitsForPromise ->
          activationPromise

        runs ->
          expect(leftEditor.find('.autocomplete')).toExist()
          expect(rightEditor.find('.autocomplete')).not.toExist()
          expect(
            RubyMotionAutocompleteView.prototype.initialize
          ).toHaveBeenCalled()

          autoCompleteView = leftEditor.find('.autocomplete').view()
          autoCompleteView.trigger 'core:cancel'
          expect(leftEditor.find('.autocomplete')).not.toExist()

          rightEditor.trigger 'rubymotion-autocomplete:toggle'
          expect(rightEditor.find('.autocomplete')).toExist()

    describe '@deactivate()', ->
      it "removes all autocomplete views and doesn't create new ones when new editors are opened", ->
        atom.workspaceView.getActiveView().trigger "rubymotion-autocomplete:toggle"

        waitsForPromise ->
          activationPromise

        runs ->
          expect(
            atom.workspaceView.getActiveView().find('.autocomplete')
          ).toExist()
          atom.packages.deactivatePackage('atom-rubymotion')
          expect(
            atom.workspaceView.getActiveView().find('.autocomplete')
          ).not.toExist()
          atom.workspaceView.getActiveView().splitRight()
          atom.workspaceView.getActiveView().
            trigger "rubymotion-autocomplete:toggle"
          expect(
            atom.workspaceView.getActiveView().find('.autocomplete')
          ).not.toExist()

describe "RubyMotionAutocompleteView", ->
  [autocomplete, editorView, editor, miniEditor] = []

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    editorView = new EditorView(editor: atom.project.openSync('sample.rb'))
    {editor} = editorView
    autocomplete = new RubyMotionAutocompleteView(editorView)
    miniEditor = autocomplete.filterEditorView

  describe 'rubymotion-autocomplete:toggle event', ->
    it "shows autocomplete view and focuses its mini-editor", ->
      editorView.attachToDom()
      expect(editorView.find('.autocomplete')).not.toExist()

      editorView.trigger "rubymotion-autocomplete:toggle"
      expect(editorView.find('.autocomplete')).toExist()
      expect(autocomplete.editor.isFocused).toBeFalsy()
      expect(autocomplete.filterEditorView.isFocused).toBeTruthy()

    describe "autocompletion", ->
      beforeEach ->
        autocomplete.snippetPrefixes = [
          'foo:'
          'foo:bar:'
        ]

      it 'autocompletes word from snippetsPrefixes', ->
        editor.getBuffer().insert([2,0] ,"fo")
        editor.setCursorBufferPosition([2,2])
        autocomplete.attach()

        expect(editor.lineForBufferRow(2)).toBe 'foo:'
        expect(editor.getCursorBufferPosition()).toEqual [2,4]
        expect(editor.getSelection().getBufferRange()).toEqual [[2,2], [2,4]]

        expect(autocomplete.list.find('li').length).toBe 2

      it 'expands snippet after confirm autocompleted word', ->
        spyOn(editorView, 'trigger').andCallThrough()
        expect(editorView.trigger).not.toHaveBeenCalled()

        editor.getBuffer().insert([2,0] ,"fo")
        editor.setCursorBufferPosition([2,2])
        autocomplete.attach()

        editorView.trigger 'core:confirm'
        expect(editorView.trigger).toHaveBeenCalled()
