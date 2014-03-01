LanguageRubymotionView = require './language-rubymotion-view'

module.exports =
  languageRubymotionView: null

  activate: (state) ->
    @languageRubymotionView = new LanguageRubymotionView(state.languageRubymotionViewState)

  deactivate: ->
    @languageRubymotionView.destroy()

  serialize: ->
    languageRubymotionViewState: @languageRubymotionView.serialize()
