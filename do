hugo
git add --all

echo -n "Commit: ";
read;
echo You typed ${REPLY}
git commit -m "$REPLY"

git push -u origin 
