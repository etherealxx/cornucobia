@tool
extends Node

@export var credit_to_test : CreditItem
@export var credit_reset_ref : CreditItem

@export var btn_test_credit: bool:
	set(v): test_credit()

@export var btn_reset_all: bool:
	set(v): reset_all()

func test_credit():
	%CreditItemDescription.fill_credits_form(credit_to_test)
	
func reset_all():
	%CreditItemDescription.fill_credits_form(credit_reset_ref)
