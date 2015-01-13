watchElements = (els, callback) ->
  [].forEach.call els, (el) ->
    el.addEventListener 'input', updateTotals, false

counter = 0

cardTemplate = ->
  counter += 1
  """
    <h1>Card ##{counter}</h1>
    <input type="text" placeholder="Description">

    <br>

    <label for="card_#{counter}_apr">APR</label>
    <input name="card_#{counter}_apr" type="number" step="0.1" value="8.9">%

    <br>

    <label for="card_#{counter}_balance">Balance</label>
    $<input name="card_#{counter}_balance" class="card-balance" type="number" value="1487.14">
    <br>

    <label for="card_#{counter}_limit">Limit</label>
    $<input name="card_#{counter}_limit" class="card-limit" type="number" value="3000">
"""

addCard = ->
  section = document.createElement('section')
  section.classList.add 'card'
  section.innerHTML = cardTemplate()
  document.querySelector('#cards').appendChild section
  watchElements([section], updateTotals)
  updateTotals()

updateTotals = ->
  totalBalance = 0
  totalLimit = 0
  totalBalance += parseInt(el.value, 10) for el in balanceEls()
  totalLimit += parseInt(el.value, 10) for el in limitEls()
  document.querySelector('.credit_limit').textContent = totalLimit
  document.querySelector('.credit_used').textContent = Math.ceil((totalBalance / totalLimit) * 100)
  document.querySelector('.credit_available').textContent = totalLimit - totalBalance

balanceEls = -> document.querySelectorAll '.card-balance'
limitEls = -> document.querySelectorAll '.card-limit'

document.querySelector('button').addEventListener 'click', addCard, false
