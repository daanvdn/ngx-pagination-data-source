#assign first parameter to version variable
$version = $args[0]

#echo "upgrading to version $version of @angular/core and @angular/cli  packages"
#ng update "@angular/core@$version" "@angular/cli$version" --create-commits
echo "upgrading to version $version of @angular-eslint packages"
ng update "@angular-eslint/builder@$version" "@angular-eslint/eslint-plugin@$version" "@angular-eslint/eslint-plugin-template@$version" "@angular-eslint/schematics@$version" "@angular-eslint/template-parser@$version" --create-commits