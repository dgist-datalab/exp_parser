#!/bin/bash
if [ $# != "2" ]; then
	echo"[usage] :$0 [src_directory] [des_directory]"
	exit
fi

./bash_parser/ssd_io_parser.sh $1 $2
./bash_parser/iops_parser.sh $1 $2
./bash_parser/qdepth_parser.sh $1 $2
./bash_parser/blk_parser.sh $1 $2 c_parser/blk_parser

