.PHONY: release real

CUDA_OBJ = cuda_wrappers gpu_functions host_functions nfa_engine burst
HOST_OBJ = cuda_allocator config_options globals half_trie sparse transition_graph state_vector utils
COMMON_HEADERS = common.h

NVCC=nvcc
SM=sm_35	# Kelper, CUDA 5-10
#SM=sm_52 	# Maxwell, CUDA 6-11
#SM=sm_61 	# Pascal, CUDA 8-
CXX=g++
CC=gcc
# GENCODE=arch=compute_80,code=sm_80	#Ampere, CUDA > 11.1
# GENCODE=arch=compute_75,code=sm_75	#Turing, CUDA > 10
GENCODE=arch=compute_70,code=sm_70	#Maxwell


######CUDA_INCLUDE=-I/usr/local/cuda/include
CUDA_INCLUDE=-I/usr/local/cuda-11.0/include

CXXFLAGS+=$(CUDA_INCLUDE) -Wno-deprecated -g
# NVCCFLAGS+=$(CUDA_INCLUDE) -Xptxas -v -arch ${SM} --compiler-options -Wno-deprecated -lineinfo -DTEXTURE_MEM_USE -g
# NVCCFLAGS+=$(CUDA_INCLUDE) -DDEBUG -Xptxas -v -arch ${SM} --compiler-options -Wno-deprecated -lineinfo -g
NVCCFLAGS+=$(CUDA_INCLUDE) -Xptxas -v -gencode=${GENCODE} --compiler-options -Wno-deprecated -lineinfo -g -G

export DYN_LIB=-lpcap -lboost_regex -lpcre

NVCCFLAGS_REL = $(NVCCFLAGS) -O0

CXXFLAGS_REL = $(CXXFLAGS) -O0

release:
	$(MAKE) -e real NVCCFLAGS="$(NVCCFLAGS_REL)" CXXFLAGS="$(CXXFLAGS_REL)"

real: nfa_engine

$(addsuffix .o, $(HOST_OBJ)) $(addsuffix .o, $(CUDA_OBJ)) : $(COMMON_HEADERS)

$(addsuffix .o, $(HOST_OBJ)) : $(addsuffix .cpp, $(basename $@)) $(addsuffix .h, $(basename $@))

$(addsuffix .o, $(CUDA_OBJ)) : $(addsuffix .cu, $(basename $@)) $(addsuffix .h, $(basename $@))
	${NVCC} $(NVCCFLAGS) -c -o $(addsuffix .o, $(basename $@)) $(addsuffix .cu, $(basename $@))
	
nfa_engine: $(addsuffix .o, $(HOST_OBJ)) $(addsuffix .o, $(CUDA_OBJ))
	${NVCC} $(NVCCFLAGS) -o nfa_engine $(addsuffix .o, $(HOST_OBJ)) $(addsuffix .o, $(CUDA_OBJ)) ${DYN_LIB}

clean:
	rm -f *.o nfa_engine
