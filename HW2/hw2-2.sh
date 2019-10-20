#!/bin/bash
size_changer(){
	echo $1 | awk '{if($0/1024^4 >=1) printf("%.2f TB",$0/1024^4); if($0/1024^3 >=1 && $0/1024^3 < 1024)printf("%.2f GB",$0/1024^3); if($0/1024^2 >=1 && $0/1024^2 < 1024)printf("%.2f MB",$0/1024^2); if($0/1024 >=1 && $0/1024 < 1024)printf("%.2f KB",$0/1024); if($0 >=1 && $0 < 1024)printf("%.2f B",$0)}'
}
cpu_info(){
	cpu_model=$(sysctl hw.model | sed 's/hw.model/CPU Model/g')
	cpu_arch=$(sysctl hw.machine_arch | sed 's/hw.machine_arch/CPU Machine/g')
	cpu_core=$(sysctl kern.smp.cpus | sed 's/kern.smp.cpus/CPU Core/g')
	dialog  --msgbox "CPU Info \n\n${cpu_model}\n\n${cpu_arch}\n\n${cpu_core}" 60 100 
}
mem_info(){
	total_mem=$(sysctl -n hw.realmem)
	mem_inactive=$(( `sysctl -n hw.pagesize` * `sysctl -n vm.stats.vm.v_inactive_count`))
	mem_cache=$(( `sysctl -n hw.pagesize` * `sysctl -n vm.stats.vm.v_cache_count`))
	mem_free=$(( `sysctl -n hw.pagesize` * `sysctl -n vm.stats.vm.v_free_count`))
	avail_mem=$(( mem_inactive + mem_cache + mem_free ))
	used_mem=$(( total_mem - avail_mem ))
	used_mem_percent=$(( used_mem * 100 / total_mem ))
	echo "${used_mem_percent}" | dialog --title "" --gauge "Memory Info and Usage \n\nTotal: `size_changer ${total_mem}`\nUsed: `size_changer ${used_mem}`\nFree: `size_changer ${avail_mem}`"  60 100 0	
	read -s key
	break
}
net_info(){
	while true
	do
		$(ifconfig | awk '$2~/^flags=/{print($1)}' | awk '{split($0,a,":"); print(a[1]);}' > /tmp/netall.output)
		count=0
		options=()
		while read -r net
		do
			options+=($((++count)) "$net")
		done < /tmp/netall.output
		cmd=(dialog --clear --menu "Network Interfaces" 60 100 16)
		choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
		if [ $? -eq 1 ] ; then
			break;
		fi
		name=${options[$((choices*2-1))]}
		ip=`ifconfig ${name} | grep "inet " | awk '{print($2);}'`
		netmask=`ifconfig ${name} | grep "inet " | awk '{print($4);}'`
		mac=`ifconfig ${name} | grep "ether" | awk '{print($2);}'`
		dialog --msgbox "Interface Name: ${name}\n\nIPv4: ${ip}\nNetmask: ${netmask}\nMac: ${mac}" 60 100
	done
}
file_info(){
	while true
	do
		now_path=$(pwd)
		$(ls -la | grep "^[-d]" | awk '{print($9);}' > /tmp/all_file.output)
		files=()
		count=0
		while read -r single_file
		do	
			file_type=`file -i ${single_file} | awk '{print($2)}' | sed 's/;//g'`
			files+=(${single_file} ${file_type})
			count=$((count+1))
		done < /tmp/all_file.output
		cmd=(dialog --clear --menu "File Browser: ${now_path}" 60 100 ${count})
		choice=$("${cmd[@]}" "${files[@]}" 2>&1 >/dev/tty)
		if [ $? -eq 1 ] ; then
			break;
		fi
		tmp=`file -i ${choice} | awk '{print($2)}' | sed 's/;//g'`
		file_size=`ls -l ${choice} | awk '{print($5)}'`
		if [ "${tmp}" == "inode/directory" ] ; then 
			cd ${choice}
		else
			file_info=$(file ${choice} | awk '{split($0,a,":");print(a[2])}')
			if [[ ${tmp} == *"text"* ]]; then
				while true
				do
					file_size=`ls -l ${choice} | awk '{print($5)}'`
					dialog --extra-button --extra-label "Edit" --msgbox "<File Name>: ${choice}\n<File Info>:${file_info}\n<File Size>: `size_changer ${file_size}`" 60 100
					result=$?
					if [ ${result} -eq 0 ] ; then
						break;
					elif [ ${result} -eq 3 ] ; then
						if [ -n "$EDITOR" ] ; then
							$EDITOR ${choice}
						else
							vim ${choice}
						fi
					fi
				done
			else
				dialog  --msgbox "<File Name>: ${choice}\n<File Info>:${file_info}\n<File Size>: `size_changer ${file_size}`" 60 100
			fi
		fi
	done
}
cpu_loading(){
	percentage=`top -d 2 | grep "^CPU" | sort -t: -k1,1 -u | sed 's/,/:/g' | awk '{split($0,a," "); print(a[10])}'`
	float=${percentage//%}
	int_percent=${float%.*}
	ans=$(( 100 - int_percent))
	echo "${ans}" | dialog --title "CPU Loading" --gauge "`top -P -d 2 | grep "^CPU" | sort -t: -k1,1 -u | sed 's/,/:/g' | awk '{split($0,a," "); print(a[1]" "a[2]" "a[4]a[3]" "a[8]a[7]" "a[12]":"a[11])}'`" 60 100 0
	read -s key
	break
}
while true
do
	dialog --clear --menu "SYS INFO" 60 100 5 \
	CPU "CPU INFO" \
	MEMORY "MEMORY INFO" \
	NETWORK "NETWORK INFO" \
	FILE "FILE BROWSER" \
	CPULOAD "CPU Loading" 2>/tmp/menu.output
	result=$?
	if [ $result -eq 1 ] ; then
		break;
	fi
	tmp=$(cat /tmp/menu.output)
	if [ $tmp = "CPU" ] ; then
		cpu_info;
	elif [ $tmp = "MEMORY" ] ; then
		mem_info;
	elif [ $tmp = "NETWORK" ] ; then
		net_info;
	elif [ $tmp = "FILE" ] ; then
		file_info;
	elif [ $tmp = "CPULOAD" ] ; then
		cpu_loading;
	fi
done
