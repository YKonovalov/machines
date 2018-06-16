all: aws.csv
.PHONY: clean

aws.json:
	echo '[]' > aws.json
	for i in `ls *.yaml|grep -v global`; do \
	  A=`python -c 'import sys, yaml, json; json.dump(yaml.load(sys.stdin), sys.stdout)' < $$i`; \
	  A=`jq --argjson a "$$A" '[.[],$$a]' aws.json`; \
	  echo "$$A" > aws.json; \
	done

global.json:
	python -c 'import sys, yaml, json; json.dump(yaml.load(sys.stdin), sys.stdout)' < global.yaml > global.json

aws.csv: global.json aws.json
	jq -r --from-file aws.jq --slurpfile g global.json aws.json >aws.csv

clean:
	rm -f global.json aws.json aws.csv
