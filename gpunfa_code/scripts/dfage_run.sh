#!/bin/bash

# *** assuming compilation is done *** 
# working dir: gpunfa-artifact/gpunfa_code/build/bin/
SRC="${GPUNFA_ROOT}/gpunfa_code/src"
echo $SRC
cd $SRC/dfage/dfa_engine
make
cd -

ALGORITHM=""    # used in gpu-artifact
BLOCK_SIZE=256
MAX_NFA_SIZE=-1
INPUT_START_POS=0
INPUT_LEN=-1
INPUT_FILENAME=""
NFA_FILENAME=""
SPLIT_CHUNK_SIZE=-1

LONG=algorithm:,block-size:,max-nfa-size:,input-start-pos:,input-len:,input_filename:,automata:,split-entire-inputstream-to-chunk-size:
SHORT=g:i:a:
# parse options
args=$(getopt -l $LONG -o $SHORT -- "$@")
eval set -- "$args"

while [ $# -ge 1 ]; do
    case "$1" in
        --)
            # no options left
            shift
            break
            ;;
        -g|--algorithm)
            ALGORITHM="$2"
            shift
            ;;
        --block-size)
            BLOCK_SIZE="$2"
            shift
            ;;
        --max-nfa-size)
            MAX_NFA_SIZE="$2"
            shift
            ;;
        --input-start-pos)
            INPUT_START_POS="$2"
            shift
            ;;
        --input-len)
            INPUT_LEN="$2"
            shift
            ;;
        -i|--input)
            INPUT_FILENAME="$2"
            shift
            ;;
        -a|--automata)
            NFA_FILENAME="$2"
            shift
            ;;
        --split-entire-inputstream-to-chunk-size)
            SPLIT_CHUNK_SIZE="$2"
            shift
            ;;
    esac
    shift
done

# TODO: implement slicing feature
INPUT_LEN=$(stat -c%s "$INPUT_FILENAME")
echo "Input length is $INPUT_LEN"
NUM_PACKETS=$((INPUT_LEN / SPLIT_CHUNK_SIZE)) 


# # test input opt parser
# echo "algorithm: $ALGORITHM"
# echo "block-size: $BLOCK_SIZE"
# echo "max-nfa-size: $MAX_NFA_SIZE"
# echo "input_start_pos: $INPUT_START_POS"
# echo "input_len: $INPUT_LEN"
# echo "input_filename: $INPUT_FILENAME"
# echo "automata: $NFA_FILENAME"
# echo "split-chunk-size: $SPLIT_CHUNK_SIZE"
# echo "number of parallel packets: $NUM_PACKETS"
# echo "transition graph file: $TRANSITION_GRAPH_FILENAME"

# -------------------------------------------------------- compile begin --------------------------------------------------------

NUMBER_OF_SUBGRAPHS=$(ls split_automata_*.anml | wc -l)

# convert split nfas from .anml to .nfa
# check if output dir already exists
for ((i = 0 ; i < $NUMBER_OF_SUBGRAPHS ; i++)); do
    vasim -Dn split_automata_$i.anml
    mv automata_0.nfa $((i+1)).nfa
    $SRC/dfage/bin/regex_memory_regen -gendfa -f $((i+1)).nfa -E $((i+1))
    mv split_automata_$i.anml ../b
    # echo "added $((i+1)).nfa"
done
cd ../

BASE="$(basename ${NFA_FILENAME} .anml)" 
echo "base name is $BASE"

n=0
while ! mkdir dfage_${BASE}_${NUMBER_OF_SUBGRAPHS}_$n
do  
    n=$((n+1))
done

mv a dfage_${BASE}_${NUMBER_OF_SUBGRAPHS}_$n/split_dfa_${NUMBER_OF_SUBGRAPHS}
mv b dfage_${BASE}_${NUMBER_OF_SUBGRAPHS}_$n/split_anml_${NUMBER_OF_SUBGRAPHS}

TRANSITION_GRAPH_FILENAME="../split_dfa"

cd dfage_${BASE}_${NUMBER_OF_SUBGRAPHS}_$n
mkdir dfage_out_${NUMBER_OF_SUBGRAPHS}_$n

# -------------------------------------------------------- compile end --------------------------------------------------------
## TODO: need to get NUMBER_OF_SUBGRAPHS if not compile
cd dfage_out_${NUMBER_OF_SUBGRAPHS}_$n

# TODO: max-nfa-size arg for infant2 unimplementated 
# run infant2 with the generated transition graph
echo "$SRC/dfage/bin/dfa_engine -a $TRANSITION_GRAPH_FILENAME -i $INPUT_FILENAME -s $INPUT_START_POS -l $INPUT_LEN -p $NUM_PACKETS -T $BLOCK_SIZE -g $NUMBER_OF_SUBGRAPHS -O 1"
$SRC/dfage/bin/dfa_engine -a $TRANSITION_GRAPH_FILENAME -i $INPUT_FILENAME -p $NUM_PACKETS -T $BLOCK_SIZE -g $NUMBER_OF_SUBGRAPHS -O 1

