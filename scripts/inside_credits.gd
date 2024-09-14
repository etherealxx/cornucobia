extends ReferenceRect

@export var credit_list : CreditItemList
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%ItemList.clear()
	for credit_item in credit_list.list:
		if credit_item:
			%ItemList.add_item(credit_item.asset_name)

func _on_item_list_item_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	var item_to_choose = %ItemList.get_item_text(index)
	for credit_item in credit_list.list:
		if credit_item.asset_name == item_to_choose:
			%CreditItemDescription.fill_credits_form(credit_item)
			break
