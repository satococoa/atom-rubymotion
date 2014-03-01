LanguageRubymotion = require '../lib/language-rubymotion'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "LanguageRubymotion", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('languageRubymotion')

  describe "when the language-rubymotion:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(atom.workspaceView.find('.language-rubymotion')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.workspaceView.trigger 'language-rubymotion:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.workspaceView.find('.language-rubymotion')).toExist()
        atom.workspaceView.trigger 'language-rubymotion:toggle'
        expect(atom.workspaceView.find('.language-rubymotion')).not.toExist()
