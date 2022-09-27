mkdir -p ${HOME}/.npm-cache || true
npm set cache ${HOME}/.npm-cache 
hash=$(md5sum "package.json" | cut -d " " -f 1)
echo "package.json md5sum is ${hash}"
gzipped="${HOME}/npm-cache/FE_${hash}_node_modules.tar.gz"
if [ ! -f ${gzipped} ]; then 
    echo "${gzipped} not found"
    npm i --prefer-offline --cache=${HOME}/.npm-cache --no-audit
    echo "gunzipping files for future use"
    tar cfz ${gzipped} node_modules
else
    echo "${gzipped} found! Extracting files"
    rm -rf node_modules/ || true
    tar xf ${gzipped}
    echo "extracted ${gzipped} to ${WORKSPACE}/node_modules"
fi