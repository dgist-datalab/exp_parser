#!/bin/bash

if [ $# != "2" ]; then
	echo"[usage] :$0 [src_directory] [des_directory]"
	exit
fi

target_fs=("ext4_data_journal" "ext4_metadata_journal" "f2fs" "xfs" "btrfs")
micro_bench_list=("copyfiles_16_gamma_fuse.f" "filemicro_createfiles_16_fuse.f" "filemicro_delete_16_fuse.f" "makedirs_16_fuse.f" "removedirs_16_fuse.f")
macro_bench_list=("fileserver_gamma_fuse.f" "varmail_gamma_fuse.f" "webproxy_gamma_fuse.f" "webserver_gamma_fuse.f")

micro_bench_checker(){
	if [[ "${micro_bench_list[@]}" =~ "${1}" ]]; then
		echo "1"
	else
		echo "0"
	fi
}

macro_bench_checker(){
	if [[ "${macro_bench_list[@]}" =~ "${1}" ]]; then
		echo "1"
	else
		echo "0"
	fi
}

#SRCD=$2/ssd_io
#SRCD_MERGE=$SRCD/merged

#rm -rf $SRCD
#mkdir -p $SRCD
#mkdir -p $SRCD_MERGE

for fs in ${target_fs[@]}
do
	for d in $(find $1$target_fs/ -type d)
	do
		target=$(basename $d)
		if [ $target == "kukania" ]; then #target directory name
			for f in $(find $d -type f)
			do
				bench_name=$(basename $f)
				bench_name="${bench_name%.*}" #$f=bench_name, $fs=filesystem name
				target_file_name=$SRCD/$fs-$bench_name.dat 

			done
		fi
	done 
done
