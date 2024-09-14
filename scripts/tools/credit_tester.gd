@tool
extends Node

@export var credit_to_test : CreditItem
@export var credit_reset_ref : CreditItem
@export var description_node : Node

@export var btn_test_credit: bool:
	set(v): test_credit()

@export var btn_reset_all: bool:
	set(v): reset_all()

func fill_form(credit_item):
	description_node.get_node("AssetName").text = credit_item.asset_name
	var owner_text = "by %s" %credit_item.asset_author
	if !credit_item.asset_author_alt_name.is_empty():
		owner_text += " (%s)" % credit_item.asset_author_alt_name
	description_node.get_node("AssetOwner").text = owner_text
	description_node.get_node("AssetType").text = "Type : %s" % credit_item.asset_type
	description_node.get_node("AssetUsage").text = "Usage : %s" % credit_item.asset_usage
	description_node.get_node("AssetMods").text = "Modification : %s" % credit_item.asset_modification
	description_node.get_node("AssetLicense").text = "License : %s" % credit_item.asset_license
	if !credit_item.asset_quote.is_empty():
		description_node.get_node("AssetQuote").show()
		description_node.get_node("AssetQuote").text = '"%s"' % credit_item.asset_quote
	else: description_node.get_node("AssetQuote").hide()
	description_node.get_node("AssetWebsite").text = "Website : %s" % credit_item.asset_website
	description_node.get_node("FullLicenseCont/AssetFullLicense").text = credit_item.asset_full_license

func test_credit():
	fill_form(credit_to_test)
	description_node.get_node("FullLicenseCont").show()
	
func reset_all():
	fill_form(credit_reset_ref)
	description_node.get_node("FullLicenseCont").hide()
