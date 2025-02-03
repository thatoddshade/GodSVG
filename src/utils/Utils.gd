class_name Utils extends RefCounted

const MAX_NUMERIC_PRECISION = 6
const MAX_ANGLE_PRECISION = 4

enum InteractionType {NONE = 0, HOVERED = 1, SELECTED = 2, HOVERED_SELECTED = 3}

# TODO Keep track of #102363.
static func is_valid_float_fixed(string: String) -> bool:
	return string.replace("E", "e").is_valid_float()

static func num_simple(number: float, decimals := -1) -> String:
	return String.num(number, decimals).trim_suffix(".0")

static func is_string_upper(string: String) -> bool:
	return string.to_upper() == string

static func is_string_lower(string: String) -> bool:
	return string.to_lower() == string

static func get_file_name(string: String) -> String:
	return string.get_file().trim_suffix("." + string.get_extension())


# Resize the control to be resized automatically to its text width, up to a maximum.
# The property name defaults account for most controls that may need to use this.
static func set_max_text_width(control: Control, max_width: float, buffer: float,
text_property := "text", font_property := "font",
font_size_property := "font_size") -> void:
	control.custom_minimum_size.x = minf(control.get_theme_font(
			font_property).get_string_size(control.get(text_property),
			HORIZONTAL_ALIGNMENT_FILL, -1,
			control.get_theme_font_size(font_size_property)).x + buffer, max_width)


static func get_cubic_bezier_points(cp1: Vector2, cp2: Vector2, cp3: Vector2,
cp4: Vector2) -> PackedVector2Array:
	var curve := Curve2D.new()
	curve.add_point(cp1, Vector2(), cp2)
	curve.add_point(cp4, cp3)
	return curve.tessellate(6, 1)

static func get_quadratic_bezier_points(cp1: Vector2, cp2: Vector2,
cp3: Vector2) -> PackedVector2Array:
	return Utils.get_cubic_bezier_points(
			cp1, 2/3.0 * (cp2 - cp1), 2/3.0 * (cp2 - cp3), cp3)

# Calculate quadratic bezier point coordinate along an axis.
static func quadratic_bezier_point(p0: float, p1: float, p2: float, t: float) -> float:
	var u := 1.0 - t
	return u * u * p0 + 2 * u * t * p1 + t * t * p2

# Calculate cubic bezier point coordinate along an axis.
static func cubic_bezier_point(p0: float, p1: float, p2: float, p3: float, t: float) -> float:
	var u := 1.0 - t
	return u * u * u * p0 + 3 * u * u * t * p1 + 3 * u * t * t * p2 + t * t * t * p3

# Ellipse parametric equation.
static func E(c: Vector2, r: Vector2, cosine: float, sine: float, t: float) -> Vector2:
	var xt := r.x * cos(t)
	var yt := r.y * sin(t)
	return c + Vector2(xt * cosine - yt * sine, xt * sine + yt * cosine)

# Ellipse parametric equation derivative (for tangents).
static func Et(r: Vector2, cosine: float, sine: float, t: float) -> Vector2:
	var xt := -r.x * sin(t)
	var yt := r.y * cos(t)
	return Vector2(xt * cosine - yt * sine, xt * sine + yt * cosine)


static func is_event_drag(event: InputEvent) -> bool:
	return event is InputEventMouseMotion and event.button_mask == MOUSE_BUTTON_LEFT

static func is_event_drag_start(event: InputEvent) -> bool:
	return event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and\
			event.is_pressed()

static func is_event_drag_end(event: InputEvent) -> bool:
	return event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and\
			event.is_released()

static func is_event_drag_cancel(event: InputEvent) -> bool:
	return event.is_action_pressed("ui_cancel") or\
			event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT


# Used to somewhat prevent unwanted inputs from triggering XNode drag & drop.
static func mouse_filter_pass_non_drag_events(event: InputEvent) -> Control.MouseFilter:
	return Control.MOUSE_FILTER_STOP if event is InputEventMouseMotion and\
			event.button_mask == MOUSE_BUTTON_MASK_LEFT else Control.MOUSE_FILTER_PASS


static func has_clipboard_web_safe() -> bool:
	if OS.has_feature("web"):
		return false
	return DisplayServer.clipboard_has()

static func get_clipboard_web_safe() -> String:
	if OS.has_feature("web"):
		return ""
	return DisplayServer.clipboard_get()
