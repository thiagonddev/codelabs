filetree() {
    IGNORE=(
        "node_modules"
        "dist"
        "build"
        "coverage"
        ".git"
        ".next"
        ".turbo"
        "package.json"
        "package-lock.json"
        "filetree.txt"
    )

    PATTERN=$(
        IFS='|'
        printf '%s' "${IGNORE[*]}"
    )

    tree --noreport -I "$PATTERN" > filetree.txt
}