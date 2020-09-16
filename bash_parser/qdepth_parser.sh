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

SRCD=$2/io_stat

rm -rf $SRCD
mkdir -p $SRCD


Q_TYPE="#bench AVG MIN MAX"

for fs in ${target_fs[@]}
do
	for d in $(find $1$target_fs/ -type d)
	do
		target=$(basename $d)
		if [ $target == "iostat" ]; then #target directory name
			echo "$Q_TYPE" >> $SRCD/micro-$fs
			echo "$Q_TYPE" >> $SRCD/macro-$fs
			for f in $(find $d -type f)
			do
				bench_name=$(basename $f)
				bench_name="${bench_name%.*}" #$f=bench_name, $fs=filesystem name
				agq_list=$(cat $f | grep "cheeze0" | awk {'print $12'})
				result="$bench_name "
				min=16384
				max=0
				sum=0
				cnt=0
				for q in ${agq_list[@]}; do
					if [ $(echo "$q < 1" | bc) == "1" ]; then
						continue;
					fi

					cnt=$((cnt+1))
					sum=$(echo "$sum + $q" | bc)
					if [ $(echo "$min > $q" | bc) == "1" ]; then
						if [ $(echo "$q > 1 " | bc) == "1" ]; then
							min=$q
						fi
					fi
					if [ $(echo "$max < $q" | bc) == "1" ]; then
						max=$q
					fi

				done
				avg=$(echo "$sum / $cnt" | bc)
				result="$result $avg $min $max"

				if [[ $(micro_bench_checker $bench_name) == 1 ]];then
					echo $result >> $SRCD/micro-$fs
				else [[ $(macro_bench_checker $bench_name) == 1 ]]
					echo $result >> $SRCD/macro-$fs
				fi
			done
		fi
	done 
done
