function init()  
  m.nameLabel = m.top.findNode("nameLabel")
  m.nameLabel.width = 150
  m.nameLabel.height = 50
end function

function onItemChange(event)
  text = m.top.item.name
  if m.top.item.isFocused
    text = "+" + text
  end if
  m.nameLabel.text =  text
end function