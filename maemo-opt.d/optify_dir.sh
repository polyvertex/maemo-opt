optify_dir () {
    f="$1"

    ff="$OPTIFY_FROM/$f"
    tf="$OPTIFY_TO/$f"

    if [ ! -e "$ff" ]; then
      # It doesn't exist yet; just create the symlink.
      echo "Optifying $ff" >&2
      mkdir -p "$tf" &&
      ln -s "$tf" "$ff"
      return;
    fi

    if [ -h "$ff" ]; then
      # It's a symlink already; check where it points and maybe warn
      # about it.
      t=$(readlink "$ff")
      if [ "$t" != "$tf" ]; then
        echo "Warning: strange symlink found during optification: $ff -> $t" >&2
      else
        echo "Already optified: $ff" >&2
      fi
      return;
    fi;

    if [ -e "$tf" ]; then
      # The destination exists.  If it is the same as the source, we are done.
      fs=$(stat "$ff" | grep "Device:")
      ts=$(stat "$tf" | grep "Device:")
      if [ "$fs" = "$ts" ]; then
        echo "Already optified: $ff" >&2
        return
      fi
    fi

    if [ -d "$ff" ]; then
      # It's a regular directory; we just copy everything over and
      # replace the source with a symlink to the destination.  While
      # copying, we have to omit symlinks that point into /opt/maemo
      # already.
      #
      # Any of the distination files might exist.  In that case, tar
      # will fail, which is the right thing, since we don't want to
      # overwrite anything.  
      #
      # XXX - However, this also means that this is not restartable.

      echo "Optifying non-empty directory $ff" >&2

      (cd "$OPTIFY_FROM" && find "$f" -type l) |
      (while read l; do
        t=$(readlink "$OPTIFY_FROM/$l"); [ "$t" = "$OPTIFY_TO/$l" ] && echo "$l";
      done) >/tmp/excludes

      (cd "$OPTIFY_FROM" && tar cf - -X /tmp/excludes "$f") | (cd "$OPTIFY_TO" && tar xf -) &&
      mv "$ff" "$ff.removed" &&
      ln -s "$tf" "$ff" &&
      rm -rf "$ff.removed"
      rc=$?

      rm /tmp/excludes

      if [ $rc -ne 0 ]; then exit $rc; fi
      return;
    fi

    # It exists but it isn't something we recognize, maybe a file.
    # Don't do anything and let dpkg deal with it.
    echo "Warning: not a directory: $ff" >&2
}
