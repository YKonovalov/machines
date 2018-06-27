def typegenerator:
  try .customizators catch empty
    | keys_unsorted as $primaryDimensions
    | [(to_entries[]|.value|[.min,.max]+[range(.incBase;.max;.inc)]|unique)]
    | combinations as $row
      | $primaryDimensions
      | with_entries({"key": .value, "value": $row[.key]});

def assignq(input):   input[.value];
def multiplyq(input): reduce .value[] as $i (1; . * input[$i]);

def levelq(input):
 .value|to_entries[]
 | .key as $k
 | .value
 | to_entries
 | reduce (.[]|[(.key|tonumber),.value]) as $i
   ([]; . + [$i])|sort
   | label $out| reduce .[] as $i
     (null; if .==null and input[$k] <= $i[0] then $i[1] else . end);

def calcq(input):
 . as $in
 | if type == "object" then (
     to_entries[]
     | if .key == "assign" then
         assignq(input)
       elif .key == "multiply" then
         multiplyq(input)
       elif .key == "level" then
         levelq(input)
       else $in end
     )
   else $in end;

def presetTypes(global; defaults; categories):
  .presetTypes|to_entries[]
  | .key as $t
  | .value
  | global[].defaults+defaults+.+categories+(.type=$t);

def customTypes(global; defaults; categories):
  .dimensions as $d
  | typegenerator as $in
  | $d
  | with_entries(.value|=(calcq($in)))
  | global[].defaults+defaults+.+categories+(.type="");

def filterArea(area):
  if area then
    . as $in
    | select( all(area|to_entries[];
              $in[.key]<=.value.max
               and
              $in[.key]>=.value.min) )
  else . end;

[
 "name", "type", "generation", "line", "workload_id",
 "arch_id", "hypervisor_id", "hypervisor_model",
 "share", "cores", "ram",
 "cpu_id", "cpu_codename", "cpu_Ghz", "cpu_turboGhz", "cpu_turboMaxGhz", "cpu_numericId",
 "gpu_id", "gpu_cores", "gpu_ram", "gpu_tensors", "gpu_numericId",
 "fpga_id", "fpga_ram", "fpga_elements", "fpga_dsp", "fpga_numericId",
 "net_id", "net_model",
 "netMbpsSla", "netMbps", "nets", "ipsPerNet",
 "nbsMbsSla", "nbsMbs", "nbsInterface",
 "lbs", "lbsGb", "lbsType"
] as $h |
($h | @csv),
 (
  .[]|.defaults as $d |
  {name,line,generation,workload} as $n |
  .aria as $a |

  presetTypes($g;$d;$n), customTypes($g;$d;$n)
   | filterArea($a)
   | (.arch[]|.id as $ai| . + ($g[].archModels[]|select(.id == $ai))|with_entries(.key |= "arch_" + .)) as $arch
   | (.hypervisor[]|.id as $hi| . + ($g[].hypervisorModels[]|select(.id == $hi))|with_entries(.key |= "hypervisor_" + .)) as $hypervisor
   | (.cpuPlatform[]|.id as $ci| . + ($g[].cpuModels[]|select(.id == $ci))|with_entries(.key |= "cpu_" + .)) as $cpu
   | (.gpuPlatform[]|.id as $gi| . + ($g[].gpuModels[]|select(.id == $gi))|with_entries(.key |= "gpu_" + .)) as $gpu
   | (.fpgaPlatform[]|.id as $fi| . + ($g[].fpgaModels[]|select(.id == $fi))|with_entries(.key |= "fpga_" + .)) as $fpga
   | (.netPlatform[]|.id as $ni| . + ($g[].netModels[]|select(.id == $ni))|with_entries(.key |= "net_" + .)) as $net
   | (.workload[]|with_entries(.key |= "workload_" + .)) as $workload
   | [ . + $arch + $hypervisor + $cpu + $gpu + $fpga + $net + $workload ]
   | (.[] | [.[$h[]]] | @csv)
 )
