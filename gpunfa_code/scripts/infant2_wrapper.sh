#!/bin/bash

# in gpunfa-artifact/gpunfa_code/build/bin/infant2/
SRC="../../../src"
cd $SRC/infant2/
make
cd -

ALGORITHM=""    # used in gpu-artifactz
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

mkdir a b 
cd a
# split input automata
~/Documents/VASim/vasim --split $NFA_FILENAME
NUMBER_OF_SUBGRAPHS=$(ls split_automata_*.anml | wc -l)

# convert split nfas from .anml to .nfa
# check if output dir already exists
for ((i = 0 ; i < $NUMBER_OF_SUBGRAPHS ; i++)); do
    ~/Documents/VASim/vasim -n split_automata_$i.anml
    mv automata_0.nfa $((i+1)).nfa
    mv split_automata_$i.anml ../b
    # echo "added $((i+1)).nfa"
done
cd ../

BASE="$(basename ${NFA_FILENAME} .anml)" 
mkdir ${BASE}_$NUMBER_OF_SUBGRAPHS
mv a ${BASE}_$NUMBER_OF_SUBGRAPHS/split_nfa_$NUMBER_OF_SUBGRAPHS
mv b ${BASE}_$NUMBER_OF_SUBGRAPHS/split_anml_$NUMBER_OF_SUBGRAPHS

TRANSITION_GRAPH_FILENAME="../split_nfa"

cd ${BASE}_$NUMBER_OF_SUBGRAPHS
mkdir infant2_out_$NUMBER_OF_SUBGRAPHS
cd infant2_out_$NUMBER_OF_SUBGRAPHS

# TODO: max-nfa-size arg for infant2 unimplementated 
# run infant2 with the generated transition graph
echo "../../../../../src/infant2/nfa_engine -a $TRANSITION_GRAPH_FILENAME -i $INPUT_FILENAME -s $INPUT_START_POS -l $INPUT_LEN -p $NUM_PACKETS -T $BLOCK_SIZE -g $NUMBER_OF_SUBGRAPHS"
../../$SRC/infant2/nfa_engine -a $TRANSITION_GRAPH_FILENAME -i $INPUT_FILENAME -s $INPUT_START_POS -l $INPUT_LEN -p $NUM_PACKETS -T $BLOCK_SIZE -g $NUMBER_OF_SUBGRAPHS


