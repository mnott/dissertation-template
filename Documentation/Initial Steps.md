
# Initial Steps

See [Basic Usage](Basic%20Usage.md) for how to get into the LaTeX shell that is used below.

The first thing you should do is to create your own directory.  Create your own blank Github repository; assuming your Github user name is `john` and your repository is `dissertation`, then do this within the `make.sh`script:

## List the currently defined Repositories

Enter `remotes` like so:

![](Attachments/latex_make_sh_remotes.png)

This shows you that there are currently one remote (`origin`) defined. If you have multiple remotes, the one you're going to use for a default  `git push` will always be the `origin` remote.

As there is already one named `origin`, you can delete or at least rename it:

![](Attachments/latex_make_sh_remotes_rename.png)

Now you've made space to add your own repository:

## Add your own Repository

You'll add your own one like so:

![](Attachments/latex_make_sh_remotes_add.png)

If you list the remotes again, you can see your repository:

![](Attachments/latex_make_sh_remotes_added.png)

## Push to your own Repository

![](Attachments/latex_make_sh_push.png)

(I've renamed my repositories before doing the push, so that I could take the screen shot; yours would be similar).

## Setup Credential Manager

It is likely that the first push will fail or rather ask you for credentials:

![](Attachments/latex_make_sh_credentials_1.png)

I chose "Sign in with your browser:"

![](Attachments/latex_make_sh_credentials_2.png)

after which I then had the required credentials installed for further  pushes.


