#!/bin/bash

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
cd ..
nvm use 16
#rm -rf ../node_modules ../package-lock.json ../out ../.next
rm -rf ../out ../.next
#yarn install
yarn export
cd scripts
# Define the range (i) here
i=19  # Change this to the desired number

# Check if the original file exists
if [ ! -f "../../out/product/[id].html" ]; then
    echo "The file index.html does not exist."
    exit 1
fi

# Loop to copy and rename the file
for num in $(seq 0 $i); do
    if [ -f "../../out/product/$num" ]; then
      rm "../../out/product/$num"
    fi
    cp "../../out/product/[id].html" "../../out/product/$num"
    echo "Copied index.html to $num"
done

#now for the products
names=("animals" "sea-creatures" "walking-on-four-legs")
# Loop to copy and rename the file
for name in "${names[@]}"; do
    if [ -f "../../out/category/$name" ]; then
        rm "../../out/category/$name"
    fi
    cp "../../out/category/[category].html" "../../out/category/$name"
    echo "Copied index.html to $name"
done


mv "../../out/cart.html" "../../out/cart"
mv "../../out/product-search.html" "../../out/product-search"