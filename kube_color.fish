function kube_color -d "set color for context"
  set -U __kube_color_bg_(string escape --style=var $argv[1]) $argv[2]
  if [ -n "$argv[3]" ]
    set -U __kube_color_fg_(string escape --style=var $argv[1]) $argv[3]
  end
  return
end