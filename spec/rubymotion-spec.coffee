# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.
{$, EditorView, WorkspaceView} = require 'atom'
RubyMotion = require '../lib/rubymotion'
RubyMotionAutocompleteView = require '../lib/rubymotion-autocomplete-view'
_ = require 'underscore-plus'

describe 'RubyMotion', ->

  # see:  https://github.com/atom/autocomplete/blob/master/spec/autocomplete-spec.coffee
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
