module screen

import gg
import camera

[heap]
pub struct Screen {
pub mut:
	ctx gg.Context
	cam camera.Camera
}
