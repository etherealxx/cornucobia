extends VBoxContainer

func _ready() -> void:
	$FullLicenseCont.hide()

func fill_credits_form(credit_item : CreditItem):
	$AssetName.text = credit_item.asset_name
	$AssetOwner.text = credit_item.asset_author
	$AssetType.text = "Type : %s" % credit_item.asset_type
	$AssetUsage.text = "Usage : %s" % credit_item.asset_usage
	$AssetLicense.text = "License : %s" % credit_item.asset_license
	if !credit_item.asset_quote.is_empty(): $AssetQuote.text = "Quote : %s" % credit_item.asset_quote
	else: $AssetQuote.hide()
	$AssetWebsite.text = "Website : %s" % credit_item.asset_website
	%AssetFullLicense.text = credit_item.asset_full_license

func _on_full_license_ask_toggled(toggled_on: bool) -> void:
	if toggled_on: $FullLicenseCont.show()
	else: $FullLicenseCont.hide()
