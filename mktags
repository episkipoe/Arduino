ctags -f tags.cpp `find . -name "*.cpp" -o -name "*.h"`
ctags -f tags.pde --langmap=c++:.pde `find . -name "*.pde"`
cat tags.cpp tags.pde > tags
sort tags -o tags
rm -f tags.*
