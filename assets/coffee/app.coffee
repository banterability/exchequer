watchElements = (els, callback) ->
  [].forEach.call els, (el) ->
    el.addEventListener 'input', updateTotals, false

updateTotals = ->
  totalBalance = 0
  totalLimit = 0
  totalBalance += parseInt(el.value, 10) for el in balanceEls
  totalLimit += parseInt(el.value, 10) for el in limitEls
  document.querySelector('.credit_limit').textContent = totalLimit
  document.querySelector('.credit_used').textContent = Math.ceil((totalBalance / totalLimit) * 100)
  document.querySelector('.credit_available').textContent = totalLimit - totalBalance

balanceEls = document.querySelectorAll '.card-balance'
limitEls = document.querySelectorAll '.card-limit'
buttonEl = document.querySelector('button')

buttonEl.addEventListener 'click', updateTotals, false

watchElements balanceEls, updateTotals
watchElements limitEls, updateTotals
