#!/usr/bin/env bash
# inject-analytics.sh <goatcounter-code>
# Fuegt das GoatCounter-Snippet vor </body> in index.html + posts/*.html ein.
# Aufruf erst nach Account-Registrierung (Code = Subdomain-Name, z.B. "dystopiashelf").
set -euo pipefail
CODE="${1:?usage: inject-analytics.sh <goatcounter-code>}"
cd "$(dirname "$0")"
SNIP="<script data-goatcounter=\"https://${CODE}.goatcounter.com/count\" async src=\"//gc.zgo.at/count.js\"></script>"
count=0
for f in index.html posts/*.html go/*.html; do
  if grep -q goatcounter "$f"; then continue; fi
  python3 - "$f" "$SNIP" <<'PY'
import sys
p,s=sys.argv[1],sys.argv[2]
t=open(p).read()
if '</body>' in t:
    t=t.replace('</body>', s+'\n</body>')
    open(p,'w').write(t)
    print('injected',p)
PY
  count=$((count+1))
done
echo "injected into $count files"
