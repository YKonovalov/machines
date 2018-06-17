[
 "generation", "line", "name",
 "type", "share", "cores", "ram",
 "cpu_id", "cpu_codename", "cpu_Ghz", "cpu_bustGhz", "cpu_bustMaxGhz", "cpu_numericId",
 "gpu_id", "gpu_cores", "gpu_ram", "gpu_tensors", "gpu_numericId",
 "fpga_id", "fpga_ram", "fpga_elements", "fpga_dsp", "fpga_numericId",
 "netMbpsSla", "netMbps", "nets", "ipsPerNet",
 "nbsMbsSla", "nbsMbs",
 "lbs", "lbsGb", "lbsType"
] as $h |
($h | @csv),
 (
  .[]|.defaults as $d |
  {name,line,generation} as $n |

  .presetTypes|to_entries[]
   | .key as $t
   | .value|$g[].defaults+$d+.+$n+(.type=$t)
   | (.cpuPlatform[]|.id as $ci| . + ($g[].cpuModels[]|select(.id == $ci))|with_entries(.key |= "cpu_" + .)) as $cpu
   | (.gpuPlatform[]|.id as $gi| . + ($g[].gpuModels[]|select(.id == $gi))|with_entries(.key |= "gpu_" + .)) as $gpu
   | (.fpgaPlatform[]|.id as $fi| . + ($g[].fpgaModels[]|select(.id == $fi))|with_entries(.key |= "fpga_" + .)) as $fpga
   | [ . + $cpu + $gpu + $fpga ]
   | (.[] | [.[$h[]]] | @csv)
 )
