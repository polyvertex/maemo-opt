optify_remove () {
    f="$1"
    
    ff="$OPTIFY_FROM/$f"
    tf="$OPTIFY_TO/$f"
    
    if [ -h "$ff" ]; then
      rm "$ff"
    else
      echo "Optify: $ff is not a symlink, not removing it".
    fi
}
