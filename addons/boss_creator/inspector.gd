@tool
extends EditorInspectorPlugin


func _can_handle(object: Object) -> bool:
	if object.get_class() == "Boss":
		return true
	else:
		return false
