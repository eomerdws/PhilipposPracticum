extends Node

# This is where all custom game side events will be created

signal transition_to_sleep
signal transition_awake


# Philippos related signals
signal dialog_calls_animation_play(character, animation)
signal philippos_health_changed(health)
signal philippos_died


# Cyndi
signal found_cyndi
signal cyndi_health_changed(health)
signal cyndi_died
