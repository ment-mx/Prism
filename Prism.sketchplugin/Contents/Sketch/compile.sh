for f in src/formats/*; do (cat "${f}"; echo); done | coffee --bare --compile --stdio > build/Formats.js
coffee --bare --compile --output build/ src/*.coffee
