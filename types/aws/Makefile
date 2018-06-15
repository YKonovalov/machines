all: aws.csv
.PHONY: clean

aws.json:
	echo '[]' > aws.json
	for i in `ls *.yaml|grep -v defaults`; do \
	  A=`python -c 'import sys, yaml, json; json.dump(yaml.load(sys.stdin), sys.stdout)' < $$i`; \
	  A=`jq --argjson a "$$A" '[.[],$$a]' aws.json`; \
	  echo "$$A" > aws.json; \
	done

defaults.json:
	python -c 'import sys, yaml, json; json.dump(yaml.load(sys.stdin), sys.stdout)' < defaults.yaml > defaults.json

aws.csv: defaults.json aws.json
	echo generation,line,name,type,cpuPlatform,share,cores,ram,netMbpsSla,netMbps,nbsMbsSla,nbsMbs,nets,ipPerNet,lbs,lbsGb,lbsType >aws.csv
	jq -r --slurpfile g defaults.json \
	 '.[]|.defaults as $$d|{name,line,generation} as $$n|.presetTypes|to_entries[]|.key as $$t|.value|$$g[].defaults+$$d+.+$$n+(.type=$$t)|[.generation,.workload,.line,.name,.type,.share,.cores,.ram,.netMbpsSla,.netMbps,.nbsMbsSla,.nbsMbs,.nets,.ipPerNet,.lbs,.lbsGb,.lbsType]|@csv' aws.json >>aws.csv
#	jq '.[]|.defaults as $d|{name,line,workload,generation} as $n|.presetTypes|with_entries(.value|= $d + $n + .)' aws.json
#	jq '.[]|.defaults as $d|{name,line,workload,generation} as $n|.presetTypes|with_entries(.key as $k|.value|= $d + $n + . + (.type=$k))|.[]' aws.json 
#	jq -r '.[]|.defaults as $d|{name,line,workload,generation} as $n|.presetTypes|to_entries[]|.key as $t|.value|$d+.+$n+(.type=$t)|[.generation,.workload,.line,.name,.type]|@tsv' aws.json
#	echo "type,cores,ram,nets,ipsPerNet,lbs,lbsSize,nbsMbs,netMbs" > aws.csv
#	jq -r '.[]|del(.pricing)|select(.generation=="current")|[.instance_type,.vCPU,.memory,.vpc.max_enis,.vpc.ips_per_eni,.storage.devices,.storage.size,.ebs_max_bandwidth,.network_performance]|@csv' instances.json >>aws.csv

clean:
	rm -f defaults.json aws.json aws.csv
