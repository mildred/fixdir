
link -in ".config/shell/environment" [glob [file join $pkgdir ".shell/*"]]
link -in ".local/bin"                [glob [file join $pkgdir ".local/bin/*"]]

