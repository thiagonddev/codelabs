dirtree() {
    echo "Directory: $(pwd)" > filesystem.txt
    tree -I 'node_modules|.git|dist|build|coverage|filesystem.txt' >> filesystem.txt
}