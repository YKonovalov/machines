all: aws.csv
.PHONY: clean dist-clean

instances.json:
	curl --progress 'https://raw.githubusercontent.com/powdahound/ec2instances.info/master/www/instances.json' -o instances.json

aws.csv: instances.json
	jq -r '.[]|del(.pricing)|select(.generation=="current")|[.instance_type,.vCPU,.memory,.vpc.max_enis,.vpc.ips_per_eni,.storage.devices,.storage.size,.ebs_max_bandwidth,.network_performance]|@csv' instances.json >aws.csv

clean:
	rm -f aws.csv

dist-clean: clean
	rm -f instances.json
