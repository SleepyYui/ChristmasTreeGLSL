import moderngl_window as mglw


class App(mglw.WindowConfig):
    window_size = 1920, 1080
    resource_dir = 'programs'

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        # print("OpenGL version:", self.wnd.ctx.version_code)
        # print("GLSL version:", self.wnd.ctx.info['GLSL_VERSION'])

        self.quad = mglw.geometry.quad_fs()
        self.program = self.load_program(vertex_shader='vertex.glsl', fragment_shader='fragment.glsl')
        self.u_scroll = 1.0

        self.texture2 = self.load_texture_2d('../textures/hex.png')
        self.texture3 = self.load_texture_2d('../textures/black_marble1.png')
        self.texture4 = self.load_texture_2d('../textures/roof/texture3.jpg')
        self.texture5 = self.load_texture_2d('../textures/red_marble1.png')
        self.texture7 = self.load_texture_2d('../textures/roof/height3.png')

        # uniforms
        self.program['u_scroll'] = self.u_scroll
        self.program['u_resolution'] = self.window_size
        self.program['u_texture2'] = 2
        self.program['u_texture3'] = 3
        self.program['u_texture4'] = 4
        self.program['u_texture5'] = 5

    def on_render(self, time, frame_time):
        self.ctx.clear()
        self.program['u_time'] = time
        self.texture2.use(location=2)
        self.texture3.use(location=3)
        self.texture4.use(location=4)
        self.texture5.use(location=5)
        self.quad.render(self.program)

    def mouse_position_event(self, x, y, dx, dy):
        self.program['u_mouse'] = (x, y)

    def mouse_scroll_event(self, x_offset, y_offset):
        self.u_scroll = max(1.0, self.u_scroll + y_offset)
        self.program['u_scroll'] = self.u_scroll


if __name__ == '__main__':
    mglw.run_window_config(App)