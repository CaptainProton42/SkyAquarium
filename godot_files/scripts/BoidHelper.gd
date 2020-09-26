# Helper autoload singleton for boids

extends Node

const palettes : Array = [[Color('#ffd22e'), Color('#ff9c24')],
                          [Color('#88ff47'), Color('#deff4a')],
                          [Color('#ff59cb'), Color('#ff3d8e')],
                          [Color('#57b0ff'), Color('#78ffef')]]

var directions : PoolVector3Array

const num_directions : int = 50

func _ready():
    directions.resize(num_directions)

    var golden_ratio : float = (1.0 + sqrt(5.0)) / 2.0
    var angle_increment : float = 2.0 * PI * golden_ratio

    for i in range(num_directions):
        var phi : float = acos(1.0 - 2.0 * i / num_directions)
        var theta : float = golden_ratio * angle_increment * i
        var direction : Vector3 = Vector3(0.0, 0.0, 0.0)
        direction.x = cos(theta) * sin(phi)
        direction.y = sin(theta) * sin(phi)
        direction.z = cos(phi)
        directions[i] = direction