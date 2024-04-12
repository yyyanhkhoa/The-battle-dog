class_name CancellationToken extends RefCounted

var _canceled: bool = false
func is_canceled() -> bool: return _canceled
	
func cancel() -> void:
	_canceled = true
