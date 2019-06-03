# homebrew-gap

*Homebrew* (<http://brew.sh/>) is the package manager for macOS.
This is the Homebrew tap for GAP, which will install the latest
official GAP release and will attempt to build as many GAP packages
as possible.

To perform GAP Homebrew installation for the first time, call

    brew install gap-system/gap/gap

To upgrade an existing GAP Homebrew installation, call

    brew upgrade gap-system/gap/gap

To run a quick test of the GAP Homebrew installation, start GAP
and then enter the following command:

    Read( Filename( DirectoriesLibrary("tst"), "testinstall.g" ));
   
Credits

The initial formula for GAP has been provided by Alexey Muranov
and has been migrated to this repository after the deprecation of 
`homebrew-science` (<https://github.com/Homebrew/homebrew-science>).
