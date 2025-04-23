extends CharacterBody2D

@export var speed := 200
@export var jump_force := -500
@export var gravedad := 1000.0
@export var gravedad_caida := 1800.0
@export var tiempo_coyote := 0.1
@onready var player: CharacterBody2D = $"."
@onready var sprite_2d: Sprite2D = $Sprite2D

@onready var colision: CollisionShape2D = $GolpeAbajo/CollisionShape2D

const ATAQUE_ABAJO := Vector2(1.0, 68.0)
const ATAQUE_ARRIBA := Vector2(0, -81.0)
const ATAQUE_LATERAL := Vector2(102.0, -1.0)
const  ATAQUE_IZQ:= Vector2(-103.0,-4.0)

var coyote_timer := 0.0
var puede_saltar := false

func _ready():
	colision.disabled = true

func _physics_process(delta):
	procesar_coyote_time(delta)
	procesar_gravedad(delta)
	procesar_movimiento()
	procesar_salto()
	procesar_ataque()
	move_and_slide()

func procesar_movimiento():
	var input_dir = Input.get_action_strength("der") - Input.get_action_strength("izq")
	velocity.x = input_dir * speed

func procesar_coyote_time(delta):
	if is_on_floor():
		coyote_timer = tiempo_coyote
	else:
		coyote_timer -= delta
	puede_saltar = coyote_timer > 0.0

func procesar_salto():
	if Input.is_action_just_pressed("saltar") and puede_saltar:
		velocity.y = jump_force
		coyote_timer = 0.0

func procesar_gravedad(delta):
	if velocity.y < 0:
		velocity.y += gravedad * delta  # Subiendo
	else:
		velocity.y += gravedad_caida * delta  # Cayendo más fuerte

func procesar_ataque():
	if Input.is_action_just_pressed("atacar"):
		if is_on_floor():
			ejecutar_ataque(ATAQUE_LATERAL)
		else:
			if Input.is_action_pressed("abajo"):
				ejecutar_ataque(ATAQUE_ABAJO)
			elif Input.is_action_pressed("der"):
				ejecutar_ataque(ATAQUE_LATERAL)
			elif Input.is_action_pressed("izq"):
				ejecutar_ataque(-ATAQUE_LATERAL)

func ejecutar_ataque(posicion: Vector2):
	colision.position = posicion
	colision.disabled = false
	await get_tree().create_timer(0.1).timeout
	colision.disabled = true


func _on_golpe_abajo_area_entered(area: Area2D) -> void:
	if area.is_in_group("Ayuda"):
		velocity.y = jump_force  # Vuelve a aplicar la fuerza de salto
