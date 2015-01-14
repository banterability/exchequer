class Card extends Backbone.Model
  defaults:
    balance: 0
    limit: 0
    rate: 18.9

  toJSON: ->
    balance: @get 'balance'
    limit: @get 'limit'
    rate: @get 'rate'

class CardView extends Backbone.View
  className: 'card'

  events:
    'input input': 'updateValues'

  model: new Card

  render: ->
    @$el.html @template @model.toJSON()
    @$el.appendTo '.cards'
    this

  tagName: 'section'

  template: (context) ->
    """
      <h1>Card ##{@cid}</h1>

      <label for="card_#{@cid}_apr">APR</label>
      <input name="card_#{@cid}_apr" data-attribute="rate" type="number" step="0.1" value="#{context.rate}">%

      <br>

      <label for="card_#{@cid}_balance">Balance</label>
      $<input name="card_#{@cid}_balance" data-attribute="balance" type="number" value="#{context.balance}">
      <br>

      <label for="card_#{@cid}_limit">Limit</label>
      $<input name="card_#{@cid}_limit" data-attribute="limit" type="number" value="#{context.limit}">
    """

  updateValues: (ev) ->
    attributeName = ev.currentTarget.dataset.attribute
    attributeValue = ev.currentTarget.value
    @model.set attributeName, attributeValue

class Wallet extends Backbone.Collection
  balance: ->
    @models.reduce (memo, model) ->
      memo + parseInt(model.get('balance'), 10)
    , 0

  limit: ->
    @models.reduce (memo, model) ->
      memo + parseInt(model.get('limit'), 10)
    , 0

  model: Card

  toJSON: ->
    totalBalance = @balance()
    totalLimit = @limit()

    available: totalBalance
    count: @length
    limit: totalLimit
    utilization: Math.ceil((totalBalance / totalLimit) * 100) || 0

class SummaryView extends Backbone.View
  addCard: ->
    newCard = new CardView
    newCard.render()
    @collection.push newCard.model

  collection: new Wallet

  events:
    'click button': 'addCard'
    'change': 'updateView'

  updateView: ->
    console.log('model change!')

  initialize: ->
    @listenTo(@collection, 'change', @render)
    @render()

  render: ->
    @$el.html @template @collection.toJSON()
    this

  template: (context = {}) ->
    """
      <h1>Summary</h1>
      <strong>Number of Accounts:</strong> <span class="credit_count">#{context.count}</span>
      <br>
      <strong>Credit Limit:</strong> $<span class="credit_limit">#{context.limit}</span>
      <br>
      <strong>Total Credit Utilization:</strong> <span class="credit_used">#{context.utilization}</span>%
      <br>
      <strong>Available Credit:</strong> $<span class="credit_available">#{context.available}</span>
      <br>
      <button>Add Card</button>
    """

(->
  window.Exchequer = new SummaryView el: '.summary'
)()
