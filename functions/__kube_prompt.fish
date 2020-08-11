# Inspired from:
# https://github.com/jonmosco/kube-ps1
# https://github.com/Ladicle/fish-kubectl-prompt

function __kube_ps_update_cache
  function __kube_ps_cache_context
    set -l ctx (kubectl config current-context 2>/dev/null)
    if /bin/test $status -eq 0
      set -g __kube_ps_context "$ctx"
    else
      set -g __kube_ps_context "n/a"
    end
  end

  function __kube_ps_cache_namespace
    set -l ns (kubectl config view --minify -o 'jsonpath={..namespace}' 2>/dev/null)
    if /bin/test -n "$ns"
      set -g __kube_ps_namespace "$ns"
    else
      set -g __kube_ps_namespace "default"
    end
  end

  set -l kubeconfig "$KUBECONFIG"
  if /bin/test -z "$kubeconfig"
    set kubeconfig "$HOME/.kube/config"
  end

  if /bin/test "$kubeconfig" != "$__kube_ps_kubeconfig"
    __kube_ps_cache_context
    __kube_ps_cache_namespace
    set -g __kube_ps_kubeconfig "$kubeconfig"
    set -g __kube_ps_timestamp (date +%s)
    return
  end

  for conf in (string split ':' "$kubeconfig")
    if /bin/test -r "$conf"
      if /bin/test -z "$__kube_ps_timestamp"; or /bin/test (/usr/bin/stat -f '%m' "$conf") -gt "$__kube_ps_timestamp"
        __kube_ps_cache_context
        __kube_ps_cache_namespace
        set -g __kube_ps_kubeconfig "$kubeconfig"
        set -g __kube_ps_timestamp (date +%s)
        return
      end
    end
  end
end

function __kube_prompt -d "show k8s context and namespace"
  if /bin/test -z "$__kube_ps_enabled"; or /bin/test $__kube_ps_enabled -ne 1
    return
  end

  __kube_ps_update_cache

  set -l color_bg $argv[1]
  set -l color_bg_key __kube_color_bg_(string escape --style=var $__kube_ps_context)
  if set -q __kube_color_bg_(string escape --style=var $__kube_ps_context)
    set color_bg $$color_bg_key
  end

  set -l color_fg $argv[2]
  set -l color_fg_key __kube_color_fg_(string escape --style=var $__kube_ps_context)
  if set -q __kube_color_fg_(string escape --style=var $__kube_ps_context)
    set color_fg $$color_fg_key
  end

  prompt_segment $color_bg $color_fg "$__kube_ps_namespace"
end
