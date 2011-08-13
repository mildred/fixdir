link ".zlogin"   "zlogin"
link ".zlogout"  "zlogout"
link ".zprofile" "zprofile"
link ".zshenv"   "zshenv"
link ".zshrc"    "zshrc"

link -in ".config/shell" [glob [file join $pkgdir "shell/*"]]

