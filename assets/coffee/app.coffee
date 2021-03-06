Humanize =
  currency: (number, symbol = '$') ->
    isNegative = false
    numString = number.toString()
    if numString.substr(0, 1) == '-'
      numString = numString.substr 1
      isNegative = true
    [dollars, cents] = numString.split '.'
    dollarStr = dollars.replace /(.)(?=(.{3})+(?!.))/, "$1,"
    if cents && parseInt(cents, 10) != 0
      "#{if isNegative then '-' else ''}$#{dollarStr}.#{cents}"
    else
      "#{if isNegative then '-' else ''}$#{dollarStr}"

class Card extends Backbone.Model
  defaults:
    balance: 0
    limit: 0
    rate: 18.9

  toJSON: ->
    balance: @get 'balance'
    cid: @cid
    limit: @get 'limit'
    rate: @get 'rate'

class CardView extends Backbone.View
  className: 'card'

  events:
    'input input': 'updateValues'

  initialize: ->
    @model = new Card

  render: ->
    @$el.html @template @model.toJSON()
    @$el.appendTo '.cards'
    this

  tagName: 'section'

  template: (context = {}) ->
    """
      <h2>Card ##{context.cid}</h2>

      <span class="field-group">
        <label for="card_#{context.cid}_apr">APR</label>
        <input name="card_#{context.cid}_apr" data-attribute="rate" type="number" step="0.1" value="#{context.rate}">%
      </span>

      <span class="field-group">
        <label for="card_#{context.cid}_balance">Balance</label>
        $<input name="card_#{context.cid}_balance" data-attribute="balance" type="number" step="100" value="#{context.balance}">
      </span>

      <span class="field-group">
        <label for="card_#{context.cid}_limit">Limit</label>
        $<input name="card_#{context.cid}_limit" data-attribute="limit" type="number" step="100" value="#{context.limit}">
      </span>
    """

  updateValues: (ev) ->
    attributeName = ev.currentTarget.dataset.attribute
    attributeValue = ev.currentTarget.value
    @model.set attributeName, attributeValue

class Wallet extends Backbone.Collection
  available: (balance, limit) ->
    limit - balance

  balance: ->
    @models.reduce (memo, model) ->
      memo + parseInt model.get('balance'), 10
    , 0

  effectiveRate: ->
    totalBalance = @balance()
    @models.reduce (memo, model) ->
      balance = parseInt model.get('balance'), 10
      rate = parseFloat model.get('rate')
      balancePercentage = balance / totalBalance
      memo + (rate * balancePercentage)
    , 0

  limit: ->
    @models.reduce (memo, model) ->
      memo + parseInt model.get('limit'), 10
    , 0

  utilization: (balance, limit) ->
    percent = Math.ceil((balance / limit) * 100)
    return '--' if percent == Infinity
    return '--' if _.isNaN(percent)
    percent

  model: Card

  toJSON: ->
    totalBalance = @balance()
    totalLimit = @limit()
    {
      available: Humanize.currency @available(totalBalance, totalLimit)
      count: @length
      effectiveRate: @effectiveRate()
      limit: Humanize.currency totalLimit
      utilization: @utilization totalBalance, totalLimit
    }

class SummaryView extends Backbone.View
  addCard: ->
    newCard = new CardView
    newCard.render()
    @collection.push newCard.model

  events:
    'click button': 'addCard'
    'change': 'updateView'

  initialize: ->
    @collection = new Wallet
    @listenTo @collection, 'change', @render
    @render()

  render: ->
    @$el.html @template @collection.toJSON()
    this

  template: (context = {}) ->
    """
      <h2>Summary</h2>
      <span class="field-group">
        <span class="label">Number of Accounts</span>
        <span class="display">#{context.count}</span>
      </span>

      <span class="field-group">
        <span class="label">Credit Limit</span>
        <span class="display">#{context.limit}</span>
      </span>

      <span class="field-group">
        <span class="label">Total Credit Utilization</span>
        <span class="display">#{context.utilization}%</span>
      </span>

      <span class="field-group">
        <span class="label">Effective APR</span>
        <span class="display">#{context.effectiveRate}%</span>
      </span>

      <span class="field-group">
        <span class="label">Available Credit</span>
        <span class="display">#{context.available}</span>
      </span>

      <br>
      <button>Add Card</button>
    """

(->
  window.Exchequer = new SummaryView el: '.summary'
)()
