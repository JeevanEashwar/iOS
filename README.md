## jMusic

### Steps for starting the project
  1. [Download/Clone](https://github.com/JeevanEashwar/jMusic/tree/GSignIn) the repository from 'GSignIn' Branch.
  2. Change Directory to jMusic Folder.
  3. Run the Command **_Pod Install_**

### Steps for hosting songs on localhost
  1. [Set up a local web server](https://discussions.apple.com/docs/DOC-12034)
  2. Add [list.php](https://github.com/JeevanEashwar/jMusic/blob/GSignIn/list.php) file to your 'Sites' folder in your mac. (ex: /Users/jeevan/Sites/list.php)
  3. Create a folder named 'jMusic' to the same Sites folder & Add mp3 files.
  4. Change the [domain](https://github.com/JeevanEashwar/jMusic/blob/GSignIn/jMusic/ViewControllers/HomeViewController.swift#L37) constant to your local address.
