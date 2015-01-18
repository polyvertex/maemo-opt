optify_file () {
    f="$1"

    ff="$OPTIFY_FROM/$f"
    tf="$OPTIFY_TO/$f"

    if [ -e "$ff" ]; then
      # Source exists.
      if [ -e "$tf" ]; then
        # Both source and destination exist already, so they better be
        # the same file already.
        fs=$(stat "$ff" | grep "Device:")
        ts=$(stat "$tf" | grep "Device:")
        if [ "$fs" = "$ts" ]; then
          echo "Already optified: $ff" >&2
          return
        else
          echo "Can't optify $ff: doesn't seem to be ours." >&2
          exit 1
        fi
      else
        # We have to move the file first.  Normally, files are unpacked
        # into their destination, but we also explicitly handle the case
        # when they aren't.
        mkdir -p "$tf" &&
        mv "$ff" "$tf" || exit 1
      fi
    fi

    ln -s "$tf" "$ff"
}
