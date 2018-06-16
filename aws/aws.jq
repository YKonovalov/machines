["generation", "line", "name", "type", "share", "cores", "ram", "netMbpsSla", "netMbps", "nbsMbsSla", "nbsMbs", "nets", "ipsPerNet", "lbs", "lbsGb", "lbsType"] as $h |
($h | @csv),
 (
  .[]|.defaults as $d |
  {name,line,generation} as $n |

  .presetTypes|to_entries[]
   | .key as $t
   | .value|[$g[].defaults+$d+.+$n+(.type=$t)]
   | (.[] | [.[$h[]]] | @csv)
 )
