#!/bin/bash

if [ $# != "2" ]; then
	echo"[usage] :$0 [src_directory] [des_directory]"
	exit
fi

target_fs=("ext4_data_journal" "ext4_metadata_journal" "f2fs" "xfs" "btrfs")
micro_bench_list=("copyfiles_16_gamma_fuse.f" "filemicro_createfiles_16_fuse.f" "filemicro_delete_16_fuse.f" "makedirs_16_fuse.f" "removedirs_16_fuse.f")
macro_bench_list=("fileserver_gamma_fuse.f" "varmail_gamma_fuse.f" "webproxy_gamma_fuse.f" "webserver_gamma_fuse.f")

SRCD=$2/ssd_io
SRCD_MERGE=$SRCD/merged

rm -rf $SRCD
mkdir -p $SRCD
mkdir -p $SRCD_MERGE

IO_TYPE="#bench TRIM MAPPINGR MAPPINGW GCMR GCMW DATAR DATAW GCDR GCDW GCMR_DGC GCMW_DGC"

for fs in ${target_fs[@]}
do
	for d in $(find $1$fs/ -type d)
	do
		target=$(basename $d)
		if [ $target == "kukania" ]; then
			echo "$IO_TYPE" >> $SRCD_MERGE/micro-$fs
			echo "$IO_TYPE" >> $SRCD_MERGE/macro-$fs
			for f in $(find $d -type f)
			do
				bench_name=$(basename $f)
				bench_name="${bench_name%.*}"
				target_file_name=$SRCD/$fs-$bench_name.dat

				micro_result=""
				macro_result=""

				if [[ "${micro_bench_list[@]}" =~ "${bench_name}" ]]; then
					micro_result="$bench_name"
				elif [[ "${macro_bench_list[@]}" =~ "${bench_name}" ]]; then
					macro_result="$bench_name"
				fi

				while read a b c; do
					case "$a" in
					( "TRIM" )		echo $a $b >> $target_file_name

				if [[ "${micro_bench_list[@]}" =~ "${bench_name}" ]]; then
					micro_result="$micro_result $b"
				elif [[ "${macro_bench_list[@]}" =~ "${bench_name}" ]]; then
					macro_result="$macro_result $b"
				fi
					;;

					( "MAPPINGR" )	echo $a $b >> $target_file_name

				if [[ "${micro_bench_list[@]}" =~ "${bench_name}" ]]; then
					micro_result="$micro_result $b"
				elif [[ "${macro_bench_list[@]}" =~ "${bench_name}" ]]; then
					macro_result="$macro_result $b"
				fi
					;;
					( "MAPPINGW" )	echo $a $b >> $target_file_name

				if [[ "${micro_bench_list[@]}" =~ "${bench_name}" ]]; then
					micro_result="$micro_result $b"
				elif [[ "${macro_bench_list[@]}" =~ "${bench_name}" ]]; then
					macro_result="$macro_result $b"
				fi
					;;
					( "GCMR" )		echo $a $b >> $target_file_name 

				if [[ "${micro_bench_list[@]}" =~ "${bench_name}" ]]; then
					micro_result="$micro_result $b"
				elif [[ "${macro_bench_list[@]}" =~ "${bench_name}" ]]; then
					macro_result="$macro_result $b"
				fi
					;;
					( "GCMW" )		echo $a $b >> $target_file_name 	

				if [[ "${micro_bench_list[@]}" =~ "${bench_name}" ]]; then
					micro_result="$micro_result $b"
				elif [[ "${macro_bench_list[@]}" =~ "${bench_name}" ]]; then
					macro_result="$macro_result $b"
				fi
					;;
					( "DATAR" )		echo $a $b >> $target_file_name 	
	
				if [[ "${micro_bench_list[@]}" =~ "${bench_name}" ]]; then
					micro_result="$micro_result $b"
				elif [[ "${macro_bench_list[@]}" =~ "${bench_name}" ]]; then
					macro_result="$macro_result $b"
				fi
					;;
					( "DATAW" )		echo $a $b >> $target_file_name 	

				if [[ "${micro_bench_list[@]}" =~ "${bench_name}" ]]; then
					micro_result="$micro_result $b"
				elif [[ "${macro_bench_list[@]}" =~ "${bench_name}" ]]; then
					macro_result="$macro_result $b"
				fi
					;;
					( "GCDR" )		echo $a $b >> $target_file_name 	

				if [[ "${micro_bench_list[@]}" =~ "${bench_name}" ]]; then
					micro_result="$micro_result $b"
				elif [[ "${macro_bench_list[@]}" =~ "${bench_name}" ]]; then
					macro_result="$macro_result $b"
				fi
					;;
					( "GCDW" )		echo $a $b >> $target_file_name

				if [[ "${micro_bench_list[@]}" =~ "${bench_name}" ]]; then
					micro_result="$micro_result $b"
				elif [[ "${macro_bench_list[@]}" =~ "${bench_name}" ]]; then
					macro_result="$macro_result $b"
				fi
					;;
					( "GCMR_DGC" )	echo $a $b >> $target_file_name 	

				if [[ "${micro_bench_list[@]}" =~ "${bench_name}" ]]; then
					micro_result="$micro_result $b"
				elif [[ "${macro_bench_list[@]}" =~ "${bench_name}" ]]; then
					macro_result="$macro_result $b"
				fi
					;;
					( "GCMW_DGC" )	echo $a $b >> $target_file_name 	

				if [[ "${micro_bench_list[@]}" =~ "${bench_name}" ]]; then
					micro_result="$micro_result $b"
				elif [[ "${macro_bench_list[@]}" =~ "${bench_name}" ]]; then
					macro_result="$macro_result $b"
				fi
					;;
					esac
				done < <(cat $f)

				if [[ "${micro_bench_list[@]}" =~ "${bench_name}" ]]; then
					echo "$micro_result" >> $SRCD_MERGE/micro-$fs
				elif [[ "${macro_bench_list[@]}" =~ "${bench_name}" ]]; then
					echo "$macro_result" >> $SRCD_MERGE/macro-$fs
				fi
			done
		fi
	done 
done
