extends VBoxContainer

var current_has_full_license = false
var current_website_link = ""

func _ready() -> void:
	$FullLicenseCont.hide()

func fill_credits_form(credit_item : CreditItem):
	$AssetName.text = credit_item.asset_name
	var owner_text = "by %s" % credit_item.asset_author
	if !credit_item.asset_author_alt_name.is_empty():
		owner_text += " (%s)" % credit_item.asset_author_alt_name
	$AssetOwner.text = "%s" % owner_text
	$AssetType.text = "Type : %s" % credit_item.asset_type
	$AssetUsage.text = "Usage : %s" % credit_item.asset_usage
	if !credit_item.asset_modification.is_empty():
		$AssetMods.show()
		$AssetMods.text = "Modification : %s" % credit_item.asset_modification
	else: $AssetMods.hide()
	$AssetLicense.text = "License : %s" % credit_item.asset_license
	if !credit_item.asset_quote.is_empty():
		$AssetQuote.show()
		$AssetQuote.text = '"%s"' % credit_item.asset_quote
	else: $AssetQuote.hide()
	$AssetWebsite.text = "Website : %s" % credit_item.asset_website
	if credit_item.asset_website.is_empty(): current_website_link = ""
	else: current_website_link = credit_item.asset_website
	%AssetFullLicense.text = credit_item.asset_full_license
	current_has_full_license = !credit_item.asset_full_license.is_empty()

func _on_full_license_ask_toggled(toggled_on: bool) -> void:
	if toggled_on: $FullLicenseCont.show() #  and current_has_full_license
	else: $FullLicenseCont.hide()

func _on_asset_website_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if !event.is_pressed(): # on release
			if not current_website_link.is_empty(): OS.shell_open(current_website_link)
	#elif event is InputEventMouseButton: # double click issue
		#if (event.pressed && event.button_index == MOUSE_BUTTON_LEFT):
			#if not current_website_link.is_empty(): OS.shell_open(current_website_link)
