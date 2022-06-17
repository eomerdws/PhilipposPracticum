extends Node

# This is where all custom game side events will be created

signal transition_to_sleep
signal transition_awake
signal transition_halfway(name)

# Philippos related signals
signal dialog_calls_animation_play(character, animation)
signal philippos_health_changed(health)
signal philippos_died


# Cyndi
signal cyndi_found
signal cyndi_health_changed(health)
signal cyndi_died
signal closest_cublins_attack_cyndi

# Dialog
signal dialog_completed
signal dialog_trigger_end
