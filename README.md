# Angular Tools
This is my own personal place to store useful scripts and tools that I have written.
I make no promises that these tools will work as described. Make sure your code is commited to source control before running my scripts on them.
I will be making changes to them as I need them. There may be missing features that I havent added yet. Most of these things work for what I am working on at the time.

## Powershell Profile
A note about the usage of the powershell scripts here; these script files are intended to be used as functions inside of your Powershell Profile. 
You can access that via `start $PROFILE` inside of a powershell window.

# Available Scripts

## Angular Split File (Angular-Split-File)
This function is intended to split inline component files out into folder organized template and component files. It doesn't do everything needed and it is not particularly optimized but its not inteded to be used that often. I wrote this to clean up an existing massive angular project that already had pretty heavy linting but almost ever file was inline component files. IMO this is ok for small components but if you are writing pages like that it is unmanageable. Use this to do 90% of the repeatative work.

### Features:
- Splits inline component files up into multiple files
- Folder seperation
- Updates References in project `.ts` files
- Removes prepended whitespace in template files

### Cons:
- Only works with Typescript file endings
- Does not update inline CSS styles(yet)
- Does not currently work with relative pathing, files need fully qualified path locations
- Whitespace removal might cause problems with differently formatted projects.

### Examples
#### Basic Split Example
The minimum you need for running this function. Make sure your file argument is fully qualified or it may cause unexpected issues.
```powershell
Split-Angular -File "C:\Users\User1\Repos\TestProject\ClientApp\src\app\shared\select-dialog.component.ts"
```

#### skipWarning
If you are using this a lot, you can skip the warning that is required to execute.
```powershell
Split-Angular -File "C:\Users\User1\Repos\TestProject\ClientApp\src\app\shared\select-dialog.component.ts" -skipWarning $true
```
#### verbose
Show more logs produced while searching for import references. Mostly useful while troubleshooting why its missing references.
```powershell
Split-Angular -File "C:\Users\User1\Repos\TestProject\ClientApp\src\app\shared\select-dialog.component.ts" -verbose $true
```
