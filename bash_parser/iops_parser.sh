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

SRCD=$2/iops
rm -rf $SRCD
mkdir -p $SRCD

for d in $(find $1$target_fs/ -type d); do
	target=$(basename $d)
	if [ $target == "perf" ]; then #target directory name
		micro_bench_name="#fs"
		macro_bench_name="#fs"
		for f in $(find $d -type f)
		do
			bench_name=$(basename $f)
			bench_name="${bench_name%.*}" #$f=bench_name, $fs=filesystem name
			result=$(grep "ops\/s" $f | grep "IO Summary" | awk {'print $6'})
			if [[ $(micro_bench_checker $bench_name) == 1 ]];then
				micro_bench_name="$micro_bench_name $bench_name"
			elif [[ $(macro_bench_checker $bench_name) == 1 ]]; then
				macro_bench_name="$macro_bench_name $bench_name"
			fi
		done
		echo $micro_bench_name >> $SRCD/micro_iops
		echo $macro_bench_name >> $SRCD/macro_iops
	fi
done

for fs in ${target_fs[@]}
do
	for d in $(find $1$fs/ -type d)
	do
		target=$(basename $d)
		if [ $target == "perf" ]; then #target directory name
			micro_result=$fs
			macro_result=$fs
			for f in $(find $d -type f)
			do
				bench_name=$(basename $f)
				bench_name="${bench_name%.*}" #$f=bench_name, $fs=filesystem name
				result=$(grep "ops\/s" $f | grep "IO Summary" | awk {'print $6'})
				if [[ $(micro_bench_checker $bench_name) == 1 ]];then
					micro_bench_name="$micro_bench_name $bench_name"
					micro_result="$micro_result $result"
				elif [[ $(macro_bench_checker $bench_name) == 1 ]]; then
					macro_bench_name="$macro_bench_name $bench_name"
					macro_result="$macro_result $result"
				fi
			done
			echo $micro_result >> $SRCD/micro_iops
			echo $macro_result >> $SRCD/macro_iops
		fi
	done 
done
