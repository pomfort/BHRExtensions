1. cd into the folder where the submodule should be
2. git submodule add <url_to_library>
3. Drag and Drop Xcodeproj into your workspace
4. Project Settings -> Link Framework
5. Project Build Settings -> Other Linker Flags -> Add '-ObjC'
6. Move Framework header file to project (don't copy)

