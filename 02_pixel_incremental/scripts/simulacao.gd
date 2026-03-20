extends Node2D

const MAX_PIXELS = 10_000_000
var rd: RenderingDevice
var shader: RID
var pipeline: RID
var buffer_pixels: RID
var contagem := 0
var tempo_total := 0.0

func _ready() -> void:
	rd = RenderingServer.get_rendering_device()
	_compilar_shader()

func _compilar_shader() -> void:
	var src = RDShaderSource.new()
	src.source_compute = """
#version 450

struct Pixel {
    vec2 pos;
    vec2 vel;
    vec4 cor;
    float tempo;
    float duracao_passo;
    float freq_x;
    float freq_y;
    float amp_x;
    float amp_y;
    float fase;
    float tipo_passo;
};

layout(set = 0, binding = 0, std430) buffer Pixels {
    Pixel pixels[];
};

layout(push_constant, std430) uniform Params {
    float delta;
    float tempo_total;
    float tela_x;
    float tela_y;
    uint contagem;
} params;

layout(local_size_x = 64, local_size_y = 1, local_size_z = 1) in;

float hash(float n) {
    return fract(sin(n) * 43758.5453123);
}

void main() {
    uint id = gl_GlobalInvocationID.x;
    if (id >= params.contagem) return;

    Pixel p = pixels[id];
    p.tempo += params.delta;

    vec2 offset = vec2(0.0);
    int tipo = int(p.tipo_passo);

    if (tipo == 0) {
        offset.x = sin(p.tempo * p.freq_x + p.fase) * p.amp_x;
        offset.y = cos(p.tempo * p.freq_y + p.fase) * p.amp_y;
    } else if (tipo == 1) {
        offset.x = cos(p.tempo * p.freq_x + p.fase) * p.amp_x;
        offset.y = sin(p.tempo * p.freq_x + p.fase) * p.amp_x;
    } else if (tipo == 2) {
        offset.x = sin(p.tempo * p.freq_x * 3.0 + p.fase) * p.amp_x * 0.4;
        offset.y = cos(p.tempo * p.freq_y * 3.0 + p.fase) * p.amp_y * 0.4;
    } else if (tipo == 3) {
        float r = (p.tempo / p.duracao_passo) * p.amp_x;
        offset.x = cos(p.tempo * p.freq_x + p.fase) * r;
        offset.y = sin(p.tempo * p.freq_y + p.fase) * r;
    } else {
        offset.x = sin(p.tempo * p.freq_x + p.fase) * p.amp_x;
        offset.y = sin(p.tempo * p.freq_y * 2.0 + p.fase) * p.amp_y * 0.5;
    }

    p.pos += offset * params.delta;

    // Rebate nas bordas
    if (p.pos.x < 0.0 || p.pos.x > params.tela_x) {
        p.vel.x *= -1.0;
        p.pos.x = clamp(p.pos.x, 0.0, params.tela_x);
    }
    if (p.pos.y < 0.0 || p.pos.y > params.tela_y) {
        p.vel.y *= -1.0;
        p.pos.y = clamp(p.pos.y, 0.0, params.tela_y);
    }

    // Troca passo quando acaba
    if (p.tempo >= p.duracao_passo) {
        p.tempo = 0.0;
        float seed = float(id) * 1.61803 + params.tempo_total;
        p.tipo_passo   = floor(hash(seed) * 5.0);
        p.duracao_passo = 0.4 + hash(seed + 1.0) * 0.8;
        p.freq_x        = 2.0 + hash(seed + 2.0) * 6.0;
        p.freq_y        = 2.0 + hash(seed + 3.0) * 6.0;
        p.amp_x         = 30.0 + hash(seed + 4.0) * 120.0;
        p.amp_y         = 30.0 + hash(seed + 5.0) * 120.0;
        p.fase          = hash(seed + 6.0) * 6.28318;
        p.cor = vec4(hash(seed + 7.0), hash(seed + 8.0), hash(seed + 9.0), 1.0);
    }

    pixels[id] = p;
}
"""
	var spirv = rd.shader_compile_spirv_from_source(src)
	if spirv.compile_error_compute != "":
		push_error("Erro no shader: " + spirv.compile_error_compute)
		return
	shader = rd.shader_create_from_spirv(spirv)
	pipeline = rd.compute_pipeline_create(shader)

func adicionar_pixels(quantidade: int, origem: Vector2) -> void:
	var novos_dados := PackedFloat32Array()
	novos_dados.resize(quantidade * 16)

	for i in range(quantidade):
		var base = i * 16
		novos_dados[base + 0]  = origem.x
		novos_dados[base + 1]  = origem.y
		novos_dados[base + 2]  = randf_range(-200, 200)
		novos_dados[base + 3]  = randf_range(-200, 200)
		novos_dados[base + 4]  = randf()
		novos_dados[base + 5]  = randf()
		novos_dados[base + 6]  = randf()
		novos_dados[base + 7]  = 1.0
		novos_dados[base + 8]  = 0.0
		novos_dados[base + 9]  = randf_range(0.4, 1.2)
		novos_dados[base + 10] = randf_range(2.0, 8.0)
		novos_dados[base + 11] = randf_range(2.0, 8.0)
		novos_dados[base + 12] = randf_range(30.0, 150.0)
		novos_dados[base + 13] = randf_range(30.0, 150.0)
		novos_dados[base + 14] = randf_range(0.0, TAU)
		novos_dados[base + 15] = float(randi() % 5)

	# Junta dados antigos com novos
	var dados_antigos := PackedFloat32Array()
	if buffer_pixels.is_valid():
		var raw = rd.buffer_get_data(buffer_pixels)
		dados_antigos = raw.to_float32_array()
		rd.free_rid(buffer_pixels)

	var dados_finais := PackedFloat32Array()
	dados_finais.append_array(dados_antigos)
	dados_finais.append_array(novos_dados)

	contagem += quantidade
	buffer_pixels = rd.storage_buffer_create(
		dados_finais.size() * 4,
		dados_finais.to_byte_array()
	)

func _process(delta: float) -> void:
	if contagem == 0:
		return
	tempo_total += delta
	_executar_shader(delta)
	queue_redraw()

func _executar_shader(delta: float) -> void:
	var tela = get_viewport().get_visible_rect().size

	# Push constants
	var push := PackedByteArray()
	push.append_array(PackedFloat32Array([
		delta,
		tempo_total,
		tela.x,
		tela.y
	]).to_byte_array())
	push.append_array(PackedInt32Array([contagem]).to_byte_array())

	var uniform := RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform.binding = 0
	uniform.add_id(buffer_pixels)
	var uniform_set = rd.uniform_set_create([uniform], shader, 0)

	var compute_list = rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	rd.compute_list_dispatch(compute_list, (contagem + 63) / 64, 1, 1)
	rd.compute_list_end()
	rd.submit()
	rd.sync()

func _draw() -> void:
	if contagem == 0:
		return
	var raw = rd.buffer_get_data(buffer_pixels)
	var dados = raw.to_float32_array()

	for i in range(contagem):
		var base = i * 16
		var pos = Vector2(dados[base], dados[base + 1])
		var cor = Color(dados[base + 4], dados[base + 5], dados[base + 6], 1.0)
		draw_rect(Rect2(pos, Vector2(2, 2)), cor)

func _exit_tree() -> void:
	if buffer_pixels.is_valid():
		rd.free_rid(buffer_pixels)
	if pipeline.is_valid():
		rd.free_rid(pipeline)
	if shader.is_valid():
		rd.free_rid(shader)
