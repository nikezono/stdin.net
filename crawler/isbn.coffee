###
#
# ISBN取得
#
###
#
module.exports = (input)->

  ISBN10 = /\b[-0-9\-X]{10,13}\b/ig
  ISBN13 = /\b[-0-9\-X]{13,17}\b/ig

  isbn10result = (input.match ISBN10)?.filter (element)->
    element = element.replace(/-/g, "")
    checkDigit = element.charAt(9)
    rawISBN    = element.substring(0,9)
    calculated = rawISBN.split('').reduce (prev,current,index)->
      prev = prev*1*10 if index is 1
      return prev + ((10-index) * current)

    calculated = 11 - calculated % 11

    calculated = 'X' if calculated is 10
    calculated = '0' if calculated is 11

    return (checkDigit.toUpperCase() == "#{calculated}")

  isbn13result = (input.match ISBN13)?.filter (element)->
    element = element.replace(/-/g, "")
    checkDigit = element.charAt(12)
    rawISBN    = element.substring(0,12)
    calculated = rawISBN.split('').reduce (prev,current,index)->
      prev = prev*1 if index is 1
      additional = if index%2 is 0 then 1 else 3
      return prev + (additional*current*1)

    calculated = 10 - calculated % 10
    calculated = "#{calculated}".slice(-1)

    return (checkDigit == calculated)

  result = [].concat(isbn10result).concat(isbn13result).filter (element)->
    return element?

  return result

