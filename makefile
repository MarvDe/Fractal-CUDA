




programm.exe: main.obj Image_O.obj CUDA_Implementations.obj
	nvcc -o programm.exe main.obj Image_o.obj CUDA_Implementations.obj

main.obj: src\main.c
	cl -c src\main.c -Iinclude

Image_O.obj: src\Image_O.c 
	cl -c src\Image_O.c -Iinclude

CUDA_Implementations.obj: src\CUDA_Implementations.cu
	nvcc -c src\CUDA_Implementations.cu -Iinclude


clean:
	del Image_O.obj main.obj CUDA_Implementations.obj programm.exe programm.exp programm.lib

