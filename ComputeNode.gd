extends Node

func _ready() -> void:
	# Create a local rendering device
	var rd := RenderingServer.create_local_rendering_device()

	# Load Compute ShaderFile
	var shader_file := load("res://compute_example.glsl")
	@warning_ignore("unsafe_method_access")
	#Get Shader
	var shader_spriv: RDShaderSPIRV = shader_file.get_spirv()
	print("Shader SPIRV", shader_spriv)

	var shader_RID := rd.shader_create_from_spirv(shader_spriv)
	print("Shader RID", shader_RID)

	# DATA
	var data := PackedFloat32Array([1,2,3,4,5,6,7,8,9,10])
	var byte_data := data.to_byte_array()
	var storage_buffer_RID := rd.storage_buffer_create(byte_data.size(), byte_data) 

	var uniform := RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform.binding = 0

	uniform.add_id(storage_buffer_RID)
	var uniform_set_RID := rd.uniform_set_create([uniform], shader_RID, 0)


	# Create a compute pipeline with the shader RID
	var pipeline_RID := rd.compute_pipeline_create(shader_RID)
	var compute_list_id := rd.compute_list_begin()

	print(pipeline_RID)
	print(compute_list_id)

	# Binds the uniform RID to the compute list id at index 0 
	rd.compute_list_bind_uniform_set(compute_list_id, uniform_set_RID, 0)

	# Tells the GPU what compute pipeline to user (pipelineRID made with shader_RID)
	rd.compute_list_bind_compute_pipeline(compute_list_id, pipeline_RID)
	# Dispatch the compute to the GPU with these sizees
	rd.compute_list_dispatch(compute_list_id, 5, 1, 1)
	# Finish the Compute Commands
	rd.compute_list_end()

	# Submit Commands to the gpu
	rd.submit()
	# Performance cost with rd.sync
	rd.sync()

	# get the data back from the storage buffer using the RID
	var output_bytes := rd.buffer_get_data(storage_buffer_RID)
	# convert to float32 array
	var output := output_bytes.to_float32_array()

	print("Input : ", data)
	print("Output : ", output)
