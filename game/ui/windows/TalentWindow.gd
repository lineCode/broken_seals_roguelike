extends PanelContainer

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

export(PackedScene) var spec_scene : PackedScene
export(PackedScene) var spec_switcher_scene : PackedScene
export(NodePath) var spec_container_path : NodePath
export(NodePath) var spec_switcher_path : NodePath

var _spec_container : Node
var _spec_switcher_container : Node

var _data : EntityData
var _player : Entity

func _ready():
	_spec_container = get_node(spec_container_path)
	_spec_switcher_container = get_node(spec_switcher_path)

func set_player(player : Entity) -> void:
	if _player != null:
		_player.disconnect("centity_data_changed", self, "centity_data_changed")
	
	_player = player
	
	if _player == null:
		return
	
	_player.connect("centity_data_changed", self, "centity_data_changed")
	
	centity_data_changed(_player.centity_data)

		
func select_spec(index : int) -> void:
	for ch in _spec_container.get_children():
		ch.hide()
	
	if _spec_container.get_child_count() <= index:
		return
	
	_spec_container.get_child(index).show()

func centity_data_changed(data: EntityData) -> void:
	if _data == data:
		return
		
	_data = data
	
	for ch in _spec_container.get_children():
		ch.queue_free()
		_spec_container.remove_child(ch)
		
	for ch in _spec_switcher_container.get_children():
		ch.queue_free()
	
	if data == null or data.entity_class_data == null:
		return

	var cd : EntityClassData = data.entity_class_data
	
	for i in range(cd.get_num_specs()):
		var spec : CharacterSpec = cd.get_spec(i)
		
		if spec == null:
			continue
			
#		var b : Node = spec_switcher_scene.instance()
#		_spec_switcher_container.add_child(b)
#		b.owner = _spec_switcher_container
#		b.set_spec_index(self, i)
			
		var s : Node = spec_scene.instance()
		_spec_container.add_child(s)
		s.owner = _spec_container
		
		if spec.text_name != "":
			s.name = spec.text_name
		
		s.set_spec(_player, spec, i)
