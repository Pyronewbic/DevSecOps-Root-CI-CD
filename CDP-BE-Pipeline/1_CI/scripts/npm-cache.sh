mkdir -p ${HOME}/.npm-cache || true
mkdir -p ${HOME}/.yarn-cache || true
npm set cache ${HOME}/.npm-cache 
hash=$(md5sum "package.json" | cut -d " " -f 1)
# gzipped="${HOME}/yarn-cache/BE_${hash}_node_modules.tar.gz"
npm config set registry https://artifactory.axisb.com/artifactory/api/npm/Corpomni-npm-remote/ \
    && npm config set ca "" \
    && npm config set strict-ssl false
gzipped="${HOME}/npm-cache/BE_${hash}_node_modules.tar.gz"
if [ ! -f ${gzipped} ]; then 
    echo "${gzipped} not found"
    npm i --only=dev --cache=${HOME}/.npm-cache --no-audit
    npm i --only=production --cache=${HOME}/.npm-cache --no-audit
    # echo "gunzipping files for future use"
    # tar cfz ${gzipped} node_modules
else
    echo "${gzipped} found! Extracting files"
    rm -rf node_modules/ || true
    tar xf ${gzipped}
    echo "extracted ${gzipped} to ${WORKSPACE}/node_modules"
fi